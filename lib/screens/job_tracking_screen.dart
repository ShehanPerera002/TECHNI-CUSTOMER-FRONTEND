import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobTrackingScreen extends StatefulWidget {
  final String workerName;
  final String serviceTitle;
  final String? jobRequestId;

  const JobTrackingScreen({
    super.key,
    required this.workerName,
    required this.serviceTitle,
    this.jobRequestId,
  });

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  bool arrived = false;
  bool workStarted = false;
  bool workDone = false;
  int timerSeconds = 0;
  DateTime? _jobStartedAt;
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = Ticker(_onTick);
    _listenToJobRequest();
  }

  void _listenToJobRequest() {
    if (widget.jobRequestId == null) return;

    FirebaseFirestore.instance
        .collection('jobRequests')
        .doc(widget.jobRequestId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || !mounted) return;
      final data = doc.data()!;
      final status = data['status'];
      
      setState(() {
        arrived = (status == 'arrived' || status == 'workStarted' || status == 'completed');
        if (status == 'workStarted' && !workStarted) {
          workStarted = true;
          final startedAt = data['jobStartedAt'];
          if (startedAt is Timestamp) {
            _jobStartedAt = startedAt.toDate();
            _resumeTimer();
          }
        }
        if (status == 'completed' && !workDone) {
          workDone = true;
          _stopTimer();
        }
      });
    });
  }

  void _onTick(Duration duration) {
    if (_jobStartedAt != null && mounted) {
      setState(() {
        timerSeconds = DateTime.now().difference(_jobStartedAt!).inSeconds;
      });
    }
  }

  void _resumeTimer() {
    if (!ticker.isActive) {
      ticker.start();
    }
  }

  void _stopTimer() {
    if (ticker.isActive) {
      ticker.stop();
    }
  }

  Future<void> _startWork() async {
    if (widget.jobRequestId == null) return;

    await FirebaseFirestore.instance
        .collection('jobRequests')
        .doc(widget.jobRequestId)
        .update({
      'status': 'workStarted',
      'jobStartedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _finishWork() async {
    if (widget.jobRequestId == null) return;

    await FirebaseFirestore.instance
        .collection('jobRequests')
        .doc(widget.jobRequestId)
        .update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'fare': _estimatePrice(timerSeconds).toDouble(),
      'durationSeconds': timerSeconds,
    });
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Job Progress'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _workerInfoCard(),
            const SizedBox(height: 24),
            _statusSection(),
            const SizedBox(height: 32),
            if (arrived && !workStarted)
              _actionButton('Start Work', _startWork, Colors.green)
            else if (workStarted && !workDone)
              _timerSection()
            else if (workDone)
              _summarySection(),
          ],
        ),
      ),
    );
  }

  Widget _workerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Text(
            widget.workerName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.serviceTitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _statusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statusIcon(Icons.location_on, 'Arrived', arrived),
        _statusConnector(arrived),
        _statusIcon(Icons.timer, 'Working', workStarted),
        _statusConnector(workStarted),
        _statusIcon(Icons.check_circle, 'Done', workDone),
      ],
    );
  }

  Widget _statusIcon(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.grey.shade400, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _statusConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Colors.blue : Colors.grey.shade200,
    );
  }

  Widget _timerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          const Text(
            'WORK IN PROGRESS',
            style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(timerSeconds),
            style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w300, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _actionButton('Finish Work', _finishWork, Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _summarySection() {
    final finalPrice = _estimatePrice(timerSeconds);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Service Completed!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 24),
          _summaryRow('Duration', _formatTime(timerSeconds)),
          const Divider(),
          _summaryRow('Total Price', 'Rs. $finalPrice'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Pay & Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return seconds >= 3600 ? '$h:$m:$s' : '$m:$s';
  }

  int _estimatePrice(int seconds) {
    // Simple price estimation: Rs. 100 per 10 minutes
    return 100 * ((seconds / 600).ceil());
  }
}

class _FeedbackForm extends StatefulWidget {
  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  final _controller = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Leave Feedback',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => _rating = i + 1),
            ),
          ),
        ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Write your feedback...'),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Navigate to rating screen after feedback
            Navigator.pushNamed(context, '/rating');
          },
          child: Text('Submit Feedback'),
        ),
      ],
    );
  }
}

// Add this dependency to pubspec.yaml:
// flutter:
//   sdk: flutter
//   ...
//   dependencies:
//     flutter:
//       sdk: flutter
//     flutter_map: ^4.0.0
//     latlong2: ^0.8.1
//     ticker: ^1.0.0
