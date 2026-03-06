import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _goToVerification() {
    if (!_isValid) return;

    Navigator.pushNamed(
      context,
      '/verification',
      arguments: "+94${_phoneController.text}",
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                decoration: InputDecoration(
                  prefixText: "+94 ",
                  hintText: "77XXXXXXX",
                  errorText: _phoneController.text.isEmpty || _isValid
                      ? null
                      : "Invalid Sri Lankan number",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _phoneController.text.isEmpty || _isValid
                          ? Colors.grey
                          : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _phoneController.text.isEmpty || _isValid
                          ? Colors.blue
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: "Continue",
                onPressed: _isValid ? _goToVerification : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
