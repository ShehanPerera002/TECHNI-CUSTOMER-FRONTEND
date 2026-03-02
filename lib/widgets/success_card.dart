import 'package:flutter/material.dart';

class SuccessCard extends StatelessWidget {
  const SuccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 24, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 110,
            width: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2F6FED),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 60),
          ),

          const SizedBox(height: 25),

          const Text(
            "Successfully Verified!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F6FED),
            ),
          ),

          const SizedBox(height: 30),

          Image.asset(
            "assets/images/verification_page2.png",
            height: 220,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
