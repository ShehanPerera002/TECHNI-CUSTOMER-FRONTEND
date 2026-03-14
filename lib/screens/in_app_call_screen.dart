import 'dart:async';

import 'package:flutter/material.dart';

import '../models/professional.dart';

/// Simulated in-app voice call screen.
class InAppCallScreen extends StatefulWidget {
  final Professional professional;

  const InAppCallScreen({super.key, required this.professional});

  @override
  State<InAppCallScreen> createState() => _InAppCallScreenState();
}

class _InAppCallScreenState extends State<InAppCallScreen> {
  bool _isConnecting = true;
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _seconds = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);
      });
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String get _formattedDuration {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() {
    _callTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.professional;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Worker avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(p.avatarUrl),
              ),
            ),
            const SizedBox(height: 24),
            // Worker name
            Text(
              p.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Status text
            Text(
              _isConnecting ? 'Calling...' : _formattedDuration,
              style: TextStyle(
                fontSize: 18,
                color: _isConnecting
                    ? Colors.white70
                    : const Color(0xFF4ADE80),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Call controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallAction(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: _isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _CallAction(
                    icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    isActive: _isSpeaker,
                    onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // End call button
            GestureDetector(
              onTap: _endCall,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CallAction({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
