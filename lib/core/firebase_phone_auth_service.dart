import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class PhoneAuthStartResult {
  const PhoneAuthStartResult({
    this.verificationId,
    this.resendToken,
    required this.autoVerified,
  });

  final String? verificationId;
  final int? resendToken;
  final bool autoVerified;
}

class PhoneAuthFailure implements Exception {
  const PhoneAuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirebasePhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _settingsApplied = false;

  static Future<void> _applyDebugSettings() async {
    if (_settingsApplied) {
      return;
    }

    _settingsApplied = true;

    // In debug builds, this lets Firebase Console test phone numbers work
    // without requiring real SMS delivery.
    if (kDebugMode) {
      await _auth.setSettings(appVerificationDisabledForTesting: true);
    }
  }

  static Future<PhoneAuthStartResult> sendOtp({
    required String phone,
    int? forceResendingToken,
  }) async {
    if (Firebase.apps.isEmpty) {
      throw const PhoneAuthFailure(
        'Firebase is not configured. Add google-services.json for Android and restart the app.',
      );
    }

    final completer = Completer<PhoneAuthStartResult>();

    try {
      await _applyDebugSettings();

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(
                const PhoneAuthStartResult(autoVerified: true),
              );
            }
          } on FirebaseAuthException catch (error) {
            if (!completer.isCompleted) {
              completer.completeError(
                PhoneAuthFailure(_mapFirebaseError(error)),
              );
            }
          } catch (_) {
            if (!completer.isCompleted) {
              completer.completeError(
                const PhoneAuthFailure('Automatic verification failed.'),
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          if (!completer.isCompleted) {
            completer.completeError(PhoneAuthFailure(_mapFirebaseError(error)));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneAuthStartResult(
                verificationId: verificationId,
                resendToken: resendToken,
                autoVerified: false,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (error) {
      throw PhoneAuthFailure(_mapFirebaseError(error));
    } catch (error) {
      throw PhoneAuthFailure('Could not start phone verification: $error');
    }

    return completer.future;
  }

  static Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw PhoneAuthFailure(_mapFirebaseError(error));
    } catch (_) {
      throw const PhoneAuthFailure(
        'OTP verification failed. Please try again.',
      );
    }
  }

  static String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP code.';
      case 'session-expired':
        return 'OTP expired. Please request a new code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded for this project.';
      case 'operation-not-allowed':
        return 'Phone sign-in is not enabled in Firebase Authentication.';
      case 'app-not-authorized':
        return 'App is not authorized in Firebase. Add SHA keys and download latest google-services.json.';
      case 'invalid-app-credential':
        return 'Invalid app credential. Check Play Integrity/SafetyNet and Firebase app setup.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Try again with network enabled.';
      case 'missing-client-identifier':
        return 'Missing Firebase client identifier. Verify google-services.json / GoogleService-Info.plist.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
