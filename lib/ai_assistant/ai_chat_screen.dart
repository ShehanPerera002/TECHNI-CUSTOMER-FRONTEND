import 'package:flutter/material.dart';
import '../widgets/app_header.dart';

// Allows users to chat with the AI assistant

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  // Controller to read user input
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "AI Assistant"),

      body: Column(
        children: [
          //Chat message area
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text("AI: Hello! How can I help you today")),
              ],
            ),
          ),

          // Message input box
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Text field where user types message
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Describe your problem...",
                    ),
                  ),
                ),

                // Photos button
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blueGrey),
                  onPressed: () {
                    // TODO: Implement upload photos functionality
                  },
                ),

                // Voice message button
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.blueGrey),
                  onPressed: () {
                    // TODO: Implement record voice functionality
                  },
                ),

                // Send button to submit the message
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implement send message functionality
                    // print(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
