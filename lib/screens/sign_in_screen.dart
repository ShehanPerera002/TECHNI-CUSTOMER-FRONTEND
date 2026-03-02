import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';
import '../core/assets.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // White (top)
              Color(0xFFEAF2FF), // Very light blue
              Color(0xFFD6E4FF), // Light blue bottom
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Image.asset(AppAssets.welcomeLogo, height: 200),

                  const SizedBox(height: 40),

                  // WELCOME TEXT
                  const Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Enter your mobile number to get started. We'll send you a code to verify your account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // MOBILE NUMBER LABEL
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mobile Number",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // MOBILE NUMBER FIELD
                  TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Your mobile number",
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CONTINUE BUTTON
                  PrimaryButton(
                    text: "Continue",
                    onPressed: () {
                      Navigator.pushNamed(context, '/verification');
                    },
                  ),

                  const SizedBox(height: 20),

                  // TERMS TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "By clicking continue, you agree to our",
                        style: TextStyle(color: Colors.black87),
                      ),
                      const Text(
                        " Terms of Service and Privacy Policy",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
