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
  late final Stopwatch stopwatch;
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    ticker = Ticker(_onTick);
  }

  void _onTick(Duration duration) {
    if (stopwatch.isRunning) {
      setState(() {
        timerSeconds = duration.inSeconds;
      });
    }
  }

  void _simulateArrival() {
    setState(() {
      arrived = true;
    });
    // TODO: Notify customer (simulate notification)
  }

  void _startWork() {
    setState(() {
      workStarted = true;
    });
    stopwatch.start();
    ticker.start();
  }

  Future<void> _finishWork() async {
    setState(() {
      workDone = true;
    });
    stopwatch.stop();
    ticker.stop();

    if (widget.jobRequestId != null) {
      await FirebaseFirestore.instance.collection('jobRequests').doc(widget.jobRequestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Worker: ${widget.workerName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Service: ${widget.serviceTitle}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (!arrived)
              ElevatedButton(
                onPressed: _simulateArrival,
                child: Text('Worker Arrived'),
              ),
            if (arrived && !workStarted)
              ElevatedButton(onPressed: _startWork, child: Text('Start Work')),
            if (workStarted && !workDone)
              Column(
                children: [
                  Text('Work in progress...', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    'Timer: ${_formatTime(timerSeconds)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _finishWork,
                    child: Text('Finish Work'),
                  ),
                ],
              ),
            if (workDone)
              Column(
                children: [
                  Text(
                    'Work Completed!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total Time: ${_formatTime(timerSeconds)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Estimated Price: Rs. ${_estimatePrice(timerSeconds)}',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text('Pay Cash & Close'),
                  ),
                  const SizedBox(height: 16),
                  _FeedbackForm(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
