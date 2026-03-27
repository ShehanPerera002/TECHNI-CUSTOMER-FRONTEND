import 'package:flutter/material.dart';

class AIWelcomeScreen extends StatelessWidget {
  const AIWelcomeScreen({super.key});

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
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Illustration Placeholder (Robot)
                    _buildIllustration(),
                    const SizedBox(height: 40),
                    const Text(
                      "Hello, it's TECHNI !",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Welcome to TECHNI!\nAI-Powered Service Matching\nReady to Connect You with\nPerfect Technicians",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Bottom Input Bar
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.bubble_chart,
            size: 250,
            color: Colors.grey.withOpacity(0.05),
          ),
          Icon(
            Icons.smart_toy_outlined,
            size: 200,
            color: Colors.grey.shade800,
          ),
          Positioned(
            bottom: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF42A5F5,
                ), // Light blue heart representation
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "TECHNI",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 30,
            left: 60,
            child: Icon(Icons.settings, color: Colors.blue, size: 28),
          ),
          const Positioned(
            top: 80,
            right: 80,
            child: Icon(Icons.person, color: Colors.blue, size: 24),
          ),
          const Positioned(
            bottom: 40,
            left: 80,
            child: Icon(Icons.build, color: Colors.grey, size: 24),
          ),
          const Positioned(
            bottom: 90,
            right: 60,
            child: Icon(Icons.location_on, color: Colors.blue, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
                onTap: () {
                  Navigator.pushNamed(context, '/chat');
                },
                decoration: const InputDecoration(
                  hintText: "Describe your issue...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
            const IconButton(
              icon: Icon(Icons.mic, color: Colors.black87),
              onPressed: null,
            ),
            const IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.black87),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
