import 'package:flutter/material.dart';
import '../core/assets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNodes[0].requestFocus(); // First box focused like image
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // exact light grey bg
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // TECHNI LOGO (LEFT ALIGNED)
              Image.asset(AppAssets.welcomeLogo, height: 28),

              const SizedBox(height: 40),

              // WORKER IMAGE (CENTERED)
              Center(
                child: Image.asset(AppAssets.workerIllustration, height: 200),
              ),

              const SizedBox(height: 40),

              // TITLE (CENTERED)
              const Center(
                child: Text(
                  "Enter Verification Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // SUBTITLE
              const Center(
                child: Text(
                  "A six-digit code has been sent to your phone number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ),

              const SizedBox(height: 35),

              // OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 65,
                    height: 65,
                    child: TextField(
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB), // light grey border
                            width: 1.5,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB), // blue when focused
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // RESEND TEXT
              Center(
                child: RichText(
                  text: const TextSpan(
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

              // VERIFY BUTTON
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
