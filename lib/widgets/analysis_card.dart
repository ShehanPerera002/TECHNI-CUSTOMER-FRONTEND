import 'package:flutter/material.dart';

// Widget used to display AI problem analysis

class AnalysisCard extends StatelessWidget {
  final String problem;

  const AnalysisCard({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,

      child: Padding(padding: const EdgeInsets.all(15), child: Text(problem)),
    );
  }
}
