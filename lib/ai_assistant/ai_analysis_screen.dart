import 'package:flutter/material.dart';

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
            const Text(
              "Problem Analysis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            //AI result Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Possible Issue.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "The washing machine may have a drainage blockage or motor issue.",
                    ),
                  ],
                ),
              ),
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
