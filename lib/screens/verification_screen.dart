import 'package:flutter/material.dart';
import 'package:technni_customer/screens/success_screen.dart';
import '../core/assets.dart';
import '../core/firebase_phone_auth_service.dart';
import '../widgets/techni_logo.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  bool _isOtpComplete = false;
  bool _isSubmitting = false;
  bool _isResending = false;
  String? _errorText;

  String? _phone;
  String? _verificationId;
  int? _resendToken;
  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();
    _focusNodes[0].requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _phone = args['phone'] as String?;
      _verificationId = args['verificationId'] as String?;
      _resendToken = args['resendToken'] as int?;
    }

    _argsLoaded = true;
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkOtpComplete() {
    String otp = _controllers.map((e) => e.text).join();
    setState(() {
      _isOtpComplete = otp.length == 6;
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next box
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-submit when all 6 digits are entered
        Future.microtask(() {
          _checkOtpComplete();
          if (_isOtpComplete) _continueToNext();
        });
        return;
      }
    } else {
      // Move back on delete
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    _checkOtpComplete();
  }

  Future<void> _continueToNext() async {
    if (!_isOtpComplete) return;

    if (_phone == null || _phone!.isEmpty || _verificationId == null) {
      setState(() {
        _errorText = 'Verification session expired. Please sign in again.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final otp = _controllers.map((e) => e.text).join();

    try {
      await FirebasePhoneAuthService.verifyOtp(
        verificationId: _verificationId!,
        otp: otp,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(phone: _phone ?? ''),
        ),
      );
    } on PhoneAuthFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'OTP verification failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_phone == null || _phone!.isEmpty || _isResending || _isSubmitting) {
      return;
    }

    setState(() {
      _isResending = true;
      _errorText = null;
    });

    try {
      final result = await FirebasePhoneAuthService.sendOtp(
        phone: _phone!,
        forceResendingToken: _resendToken,
      );

      if (!mounted) return;

      if (result.autoVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(phone: _phone ?? ''),
          ),
        );
        return;
      }

      if (result.verificationId == null || result.verificationId!.isEmpty) {
        throw const PhoneAuthFailure('Could not resend OTP. Please try again.');
      }

      setState(() {
        _verificationId = result.verificationId;
        _resendToken = result.resendToken;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP code resent successfully.')),
      );
    } on PhoneAuthFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const TechniLogo(),

              const SizedBox(height: 40),

              Center(
                child: Image.asset(AppAssets.workerIllustration, height: 200),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  "Enter Verification Code",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "A six-digit code has been sent to your phone number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 55,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textInputAction: index == 5
                          ? TextInputAction.done
                          : TextInputAction.next,
                      onChanged: (value) => _onOtpChanged(value, index),
                      onSubmitted: index == 5 ? (_) => _continueToNext() : null,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              Center(
                child: GestureDetector(
                  onTap: _isResending ? null : _resendCode,
                  child: Text.rich(
                    TextSpan(
                      text: "Didn't receive the code? ",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      children: [
                        TextSpan(
                          text: _isResending ? 'Resending...' : 'Resend Code',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: _isOtpComplete && !_isSubmitting
                    ? _continueToNext
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: _isOtpComplete && !_isSubmitting
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          )
                        : null,
                    color: _isOtpComplete && !_isSubmitting
                        ? null
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      _isSubmitting ? 'Verifying...' : 'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
