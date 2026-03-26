import 'package:flutter/material.dart';
import '../widgets/checklist_item.dart';

//This screen shows safety steps before calling a technician
class AiChecklistScreen extends StatelessWidget {
  const AiChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safety Checklist")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please check the following",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            //Checklist items
            const ChecklistItem(text: "Check power connection"),
            const ChecklistItem(text: "Restart the appliance"),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/technician");
                },
                child: const Text("View Recommended Technicians"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
