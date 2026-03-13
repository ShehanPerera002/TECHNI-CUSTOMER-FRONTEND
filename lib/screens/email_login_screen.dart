import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

    try {
      await _ensureFirebaseAuthAccount(email, password);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.code == 'wrong-password' ||
            error.code == 'invalid-credential' ||
            error.code == 'invalid-email') {
          _errorText = 'Incorrect email or password.';
        } else if (error.code == 'operation-not-allowed') {
          _errorText =
              'Email/password login is disabled in Firebase Authentication.';
        } else if (error.code == 'admin-restricted-operation') {
          _errorText =
              'This operation is restricted by Firebase settings. Please enable Email/Password sign-in method.';
        } else {
          _errorText = error.message ?? 'Failed to login. Please try again.';
        }
      });
    } catch (_) {
      if (!mounted) return;
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
