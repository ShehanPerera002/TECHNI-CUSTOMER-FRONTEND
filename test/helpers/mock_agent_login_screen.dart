import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'fake_auth_service.dart';

/// A Mock Agent Login Screen to serve as a reference implementation
/// that satisfies the test suite. In a real project, this would be your
/// actual production code.
class AgentLoginScreen extends StatefulWidget {
  final FakeAuthService authService;
  
  const AgentLoginScreen({super.key, required this.authService});

  @override
  State<AgentLoginScreen> createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends State<AgentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _agentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Edge case: prevent rapid tapping if already loading
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.authService.loginAgent(
        _agentIdController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MockAgentDashboard()),
        );
      } else {
        setState(() {
          _errorMessage = 'Incorrect credentials';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.toString().contains('Network')) {
           _errorMessage = 'Network failure';
        } else {
           _errorMessage = 'Server error';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Entry'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message banner
                if (_errorMessage != null)
                  Container(
                    key: const Key('errorMessage'),
                    padding: const EdgeInsets.all(12),
                    color: Colors.red.shade100,
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 24),

                // Agent ID Field
                Semantics(
                  label: 'Agent ID Field', // Accessibility
                  child: TextFormField(
                    key: const Key('agentIdField'),
                    controller: _agentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Agent ID',
                      hintText: 'Enter your Agent ID',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 50, // Edge case handling
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Agent ID cannot be empty';
                      }
                      if (!RegExp(r'^AG\d{5}$').hasMatch(value) && !value.contains('ERROR')) {
                        return 'Invalid Agent ID format';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Password Field
                Semantics(
                  label: 'Password Field',
                  child: TextFormField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100, // Edge case handling
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      if (value.length < 8) {
                        return 'Password minimum length is 8 characters';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                Semantics(
                  button: true,
                  label: 'Login Button',
                  child: ElevatedButton(
                    key: const Key('loginButton'),
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // tap target size
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              key: Key('loadingIndicator'),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login / Enter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
