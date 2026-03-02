import 'package:flutter/material.dart';
import '../widgets/success_card.dart';
import '../core/assets.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 25,
              left: 24,
              child: Image.asset(
                AppAssets.welcomeLogo,
                height: 40, // adjusted for proper proportion
                fit: BoxFit.contain,
              ),
            ),
            const Center(child: SuccessCard()),
          ],
        ),
      ),
    );
  }
}
