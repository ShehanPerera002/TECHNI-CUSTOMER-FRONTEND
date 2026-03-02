import 'package:flutter/material.dart';
import '../widgets/success_card.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: const [
                  Icon(Icons.build, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    "TECHNI",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Center(child: SuccessCard()),
          ],
        ),
      ),
    );
  }
}
