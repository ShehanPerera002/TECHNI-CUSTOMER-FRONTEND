import 'package:flutter/material.dart';

class TechniLogo extends StatelessWidget {
  const TechniLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF3BA6F8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 10),
        const Text(
          'TECHNI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: 0.6,
            height: 1,
          ),
        ),
      ],
    );
  }
}
