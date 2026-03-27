import 'package:flutter/material.dart';

class AiChecklistScreen extends StatelessWidget {
  const AiChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "TECHNI",
          style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildBotBanner("🚨 WHILE YOU WAIT HERE'S WHAT YOU CAN DO"),
                _buildChecklistCard(),
                
                // User Button Bubble
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/technician');
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12, left: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Ok",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                
                _buildBotBubble("Great! Let me know when you've completed these steps, or if you need any clarification"),
                _buildBotBubble("Searching for available emergency plumbers in your area... 🔍"),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBotBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildBotBanner(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🔧 IMMEDIATE ACTIONS", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRow("1. ", "Turn off water main valve"),
          _buildRow("2. ", "Place buckets under the leak"),
          _buildRow("3. ", "Take photos for insurance"),
          _buildRow("4. ", "Clear access path to kitchen"),
          const Divider(height: 24),
          const Text("📋 PREPARATION CHECKLIST", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRow("[ ] ", "Move items from under sink"),
          _buildRow("[ ] ", "Wipe excess water from floor"),
          _buildRow("[ ] ", "Have towels ready for cleanup"),
          _buildRow("[ ] ", "Keep pets in separate room"),
        ],
      ),
    );
  }

  Widget _buildRow(String prefix, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prefix, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Ask Techni",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
            const IconButton(icon: Icon(Icons.mic, color: Colors.black87), onPressed: null),
            const IconButton(icon: Icon(Icons.camera_alt, color: Colors.black87), onPressed: null),
          ],
        ),
      ),
    );
  }
}
