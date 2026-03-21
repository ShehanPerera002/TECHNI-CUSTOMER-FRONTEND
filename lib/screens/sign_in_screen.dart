import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/firebase_phone_auth_service.dart';
import 'success_screen.dart';
import '../widgets/primary_button.dart';
import '../core/assets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool _isValid = false;
  bool _isSubmitting = false;
  String? _errorText;

  // Sri Lankan mobile regex
  final RegExp _sriLankaRegex = RegExp(r'^(70|71|72|74|75|76|77|78)\d{7}$');

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    String phone = _phoneController.text;

    // Auto remove leading 0
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
      _phoneController.value = TextEditingValue(
        text: phone,
        selection: TextSelection.collapsed(offset: phone.length),
      );
    }

    setState(() {
      _isValid = _sriLankaRegex.hasMatch(phone);
    });
  }

  Future<void> _goToVerification() async {
    if (!_isValid) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final phone = '+94${_phoneController.text}';

    try {
      final result = await FirebasePhoneAuthService.sendOtp(phone: phone);

      if (!mounted) return;

      if (result.autoVerified) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SuccessScreen(phone: phone)),
        );
        return;
      }

      if (result.verificationId == null || result.verificationId!.isEmpty) {
        throw const PhoneAuthFailure('Failed to start OTP verification.');
      }

      await Navigator.pushNamed(
        context,
        '/verification',
        arguments: {
          'phone': phone,
          'verificationId': result.verificationId,
          'resendToken': result.resendToken,
        },
      );
    } on PhoneAuthFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to send OTP: $error';
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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color techniBrand = Color(0xFF2563EB);

    return PopScope(
      canPop: _phoneController.text.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _phoneController.clear();
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(child: Image.asset(AppAssets.welcomeLogo, height: 180)),
                  const SizedBox(height: 40),
                  const Text(
                    "Enter your mobile number",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _goToVerification(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixText: "+94 ",
                      prefixStyle: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "77XXXXXXX",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      errorText: _phoneController.text.isEmpty || _isValid
                          ? null
                          : "Invalid Sri Lankan number",
                      errorStyle: const TextStyle(color: Color(0xFFDC2626)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _phoneController.text.isEmpty || _isValid
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _phoneController.text.isEmpty || _isValid
                              ? techniBrand
                              : const Color(0xFFDC2626),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDC2626)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFDC2626),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ),
                  PrimaryButton(
                    text: _isSubmitting ? 'Sending...' : 'Continue',
                    onPressed: _isValid && !_isSubmitting
                        ? _goToVerification
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
