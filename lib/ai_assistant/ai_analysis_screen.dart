import 'package:flutter/material.dart';
import '../widgets/section_title.dart';
import '../widgets/analysis_card.dart';

// This screen shows the AI analysis of the user`s problem
class AiAnalysisScreen extends StatelessWidget {
  const AiAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Analysis")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Title
            const SectionTitle(title: "Problem Analysis"),

            const SizedBox(height: 20),

            //AI result Card
            const AnalysisCard(
              problem:
                  "The washing machine may have a drainage blockage or motor issue.",
            ),

            const SizedBox(height: 20),

            //Next button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/checklist");
                },
                child: const Text("View Safety Checklist"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
