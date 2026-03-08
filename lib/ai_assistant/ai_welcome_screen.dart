import 'package:flutter/material.dart';
import '../widgets/app_header.dart';

// shows the welcome page for the AI Assistant
class AIWelcomeScreen extends StatelessWidget {
  const AIWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //App bar with title
      appBar: const AppHeader(title: "AI Assistant"),

      // Main content of the AI welcome screen
      body: Center(
        // Center the columnn both vertically and horizontally
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            //Robot Icon represent the AI assistant
            const Icon(Icons.smart_toy, size: 100, color: Colors.blue),

            const SizedBox(height: 20), // Space between icon and text
            // Welcome message
            const Text(
              "Hello! I'm your AI Assistant",
              style: TextStyle(fontSize: 20), // Larger font size
            ),

            const SizedBox(height: 20), // Space before the button
            // Button to start chat
            ElevatedButton(
              onPressed: () {
                // Navigate the chat screen when pressed
                Navigator.pushNamed(context, '/chat');
              },
              child: const Text("Start chat"),
            ),
          ],
        ),
      ),
    );
  }
}
