import 'package:flutter/material.dart';
import 'package:technni_customer/screens/success_screen.dart';
import '../core/assets.dart';

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

  @override
  void initState() {
    super.initState();
    _focusNodes[0].requestFocus();
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
      }
    } else {
      // Move back on delete
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    _checkOtpComplete();
  }

  void _verifyOtp() {
    if (!_isOtpComplete) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Image.asset(AppAssets.welcomeLogo, height: 28),

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
                      onChanged: (value) => _onOtpChanged(value, index),
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

              const Center(
                child: Text.rich(
                  TextSpan(
                    text: "Didn’t receive the code? ",
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    children: [
                      TextSpan(
                        text: "Resend Code",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: _isOtpComplete ? _verifyOtp : null,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: _isOtpComplete
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          )
                        : null,
                    color: _isOtpComplete ? null : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Verify",
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
