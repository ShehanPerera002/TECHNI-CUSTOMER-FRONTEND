import 'package:flutter/material.dart';
import '../widgets/success_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/techni_logo.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, this.phone = ''});

  final String phone;

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
              const TechniLogo(),
              const Spacer(),
              const Center(child: SuccessCard()),
              const Spacer(),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/createProfile',
                    arguments: {'phone': phone},
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
