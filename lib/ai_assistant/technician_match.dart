import 'package:flutter/material.dart';

class TechnicianMatchScreen extends StatelessWidget {
  const TechnicianMatchScreen({super.key});

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
                _buildBotBanner("🛠 SERVICE MATCH FOUND"),
                _buildMatchCard(),
                _buildQuickActionsCard(),
              ],
            ),
          ),
          _buildInputBar(),
        ],
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

  Widget _buildMatchCard() {
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
          const Text("🎯 PERFECT MATCH IDENTIFIED!", style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRow("🔴", "Problem: Kitchen Sink Pipe Leak"),
          _buildRow("🔴", "Urgency: HIGH | Immediate attention needed"),
          const Divider(height: 24),
          const Text("👤 RECOMMENDED TECHNICIAN", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("👨‍🔧 Saman Perera", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text(
            "⭐ 4.9/5 (247 reviews)\n🛠 Plumbing Specialist\n📍 1.2 km away | ⏱ 15 min ETA",
            style: TextStyle(color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 12),
          _buildRow("✅", "AI MATCH SCORE: 96%"),
          _buildRow("✅", "Specializes in emergency kitchen leaks"),
          _buildRow("✅", "Carries all required tools & parts"),
          _buildRow("✅", "98% success rate with similar jobs"),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EFFF), // Light blue box for quick actions
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("💡 QUICK ACTIONS", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionButton(Icons.phone, "Connect Now", "All calls encrypted\nfor your privacy", Colors.blue),
              _buildActionButton(Icons.person, "Check Profile", "Check worker's profile\nbefore connect", Colors.blue),
              _buildActionButton(Icons.search, "See Others", "Search for another\nworker suitable for you", Colors.blue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String title, String subtitle, Color color) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(radius: 20, backgroundColor: color, child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
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
