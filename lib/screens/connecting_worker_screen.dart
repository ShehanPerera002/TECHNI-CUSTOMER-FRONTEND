import 'dart:async';

import 'package:flutter/material.dart';

import '../models/professional.dart';
import 'worker_on_the_way_screen.dart';

class ConnectingWorkerScreen extends StatefulWidget {
  final Professional professional;
  final String serviceTitle;

  const ConnectingWorkerScreen({
    super.key,
    required this.professional,
    required this.serviceTitle,
  });

  @override
  State<ConnectingWorkerScreen> createState() => _ConnectingWorkerScreenState();
}

class _ConnectingWorkerScreenState extends State<ConnectingWorkerScreen> {
  Timer? _progressTimer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      setState(() => _progress = (_progress + 0.03).clamp(0.0, 1.0));
      if (_progress >= 1.0) {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WorkerOnTheWayScreen(
              professional: widget.professional,
              serviceTitle: widget.serviceTitle,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final professional = widget.professional;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 78,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: CircleAvatar(
                      radius: 74,
                      backgroundImage: NetworkImage(professional.avatarUrl),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                professional.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 54),
              const Text(
                'Connecting...',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Please wait while we reach the professional',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Color(0xFF8D8D8D)),
              ),
              const SizedBox(height: 36),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: _progress,
                  backgroundColor: const Color(0xFFE1E1E1),
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 230,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE3E3E3),
                    foregroundColor: const Color(0xFF686868),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
