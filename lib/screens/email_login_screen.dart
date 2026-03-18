import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/session_manager.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorText;

  bool get _isFormValid {
    return _emailController.text.trim().isNotEmpty &&
        _emailController.text.contains('@') &&
        _passwordController.text.isNotEmpty;
  }

  Future<bool> _ensureFirebaseAuthAccount(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (error) {
      if (error.code != 'user-not-found') {
        rethrow;
      }

      try {
        if (FirebaseAuth.instance.currentUser?.isAnonymous ?? false) {
          await FirebaseAuth.instance.signOut();
        }
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return true;
      } on FirebaseAuthException catch (createError) {
        if (createError.code == 'email-already-in-use') {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return true;
        }
        rethrow;
      }
    }
  }

  Future<void> _loginWithEmailPassword() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String trimmedEmail = email.trim();
    final String lowerEmail = trimmedEmail.toLowerCase();
    final String trimmedPassword = password.trim();

    try {
      await _ensureFirebaseAuthAccount(email, password);

      if (!mounted) return;

      // Check if customer profile already exists
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (doc.exists) {
          SessionManager.setCustomerDocId(user.uid);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          return;
        } else {
          // Profile might exist under a different UID (e.g., from phone auth sign-up)
          final emailQuery = await FirebaseFirestore.instance
              .collection('customers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          // Also try case-insensitive lookup
          final QuerySnapshot effectiveQuery;
          if (emailQuery.docs.isNotEmpty) {
            effectiveQuery = emailQuery;
          } else {
            effectiveQuery = await FirebaseFirestore.instance
                .collection('customers')
                .where('emailLower', isEqualTo: email.toLowerCase())
                .limit(1)
                .get();
          }

          if (!mounted) return;

          if (effectiveQuery.docs.isNotEmpty) {
            // Migrate profile to current auth UID
            final existingData = Map<String, dynamic>.from(effectiveQuery.docs.first.data() as Map);
            existingData['uid'] = user.uid;
            await FirebaseFirestore.instance
                .collection('customers')
                .doc(user.uid)
                .set(existingData, SetOptions(merge: true));

            SessionManager.setCustomerDocId(user.uid);
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            return;
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/createProfile',
            (route) => false,
            arguments: {'phone': '', 'email': email},
          );
          return;
        }
      }
    } on FirebaseAuthException {
      // If Firebase Auth login fails, try Firestore-based login (INSECURE)
      try {
        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('customers')
            .where('email', isEqualTo: trimmedEmail)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          query = await FirebaseFirestore.instance
              .collection('customers')
              .where('emailLower', isEqualTo: lowerEmail)
              .limit(1)
              .get();
        }
        print('[DEBUG] Firestore query docs count: ${query.docs.length}');
        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data() as Map<String, dynamic>;
          print('[DEBUG] Firestore login data: $data');
          final firestorePassword = data['password']?.toString().trim();
          print('[DEBUG] Firestore password: ${firestorePassword ?? 'null'}');
          print('[DEBUG] Entered password: $trimmedPassword');
          if (firestorePassword == null) {
            setState(() {
              _errorText = 'No password set for this user in Firestore.';
            });
            return;
          }
          if (firestorePassword == trimmedPassword) {
            // Store the Firestore doc ID so profile screen can find it
            final docId = query.docs.first.id;
            SessionManager.setCustomerDocId(docId);

            // Try to establish Firebase Auth session
            try {
              await _ensureFirebaseAuthAccount(lowerEmail, trimmedPassword);
              // If Firebase Auth succeeded, also migrate profile doc
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && docId != currentUser.uid) {
                final migrateData = Map<String, dynamic>.from(data);
                migrateData['uid'] = currentUser.uid;
                await FirebaseFirestore.instance
                    .collection('customers')
                    .doc(currentUser.uid)
                    .set(migrateData, SetOptions(merge: true));
                SessionManager.setCustomerDocId(currentUser.uid);
              }
            } catch (_) {
              // Firebase Auth failed — continue with Firestore doc ID only
            }

            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
            return;
          } else {
            setState(() {
              _errorText = 'Incorrect email or password.';
            });
            return;
          }
        } else {
          setState(() {
            _errorText = 'No user found with this email.';
          });
          print('[DEBUG] No user found with this email in Firestore.');
        }
      } catch (e) {
        print('[DEBUG] Firestore login error: $e');
        setState(() {
          _errorText = 'Failed to login. Please try again.';
        });
      }
    } catch (_) {
      setState(() {
        _errorText = 'Failed to login. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Login', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sign in with email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isFormValid && !_isSubmitting
                      ? _loginWithEmailPassword
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isSubmitting ? 'Logging in...' : 'Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
