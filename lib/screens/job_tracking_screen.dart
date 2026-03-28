import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'emergency_help_screen.dart';
import 'feedback_screen.dart';

class JobTrackingScreen extends StatefulWidget {
  final String workerName;
  final String serviceTitle;
  final String? jobRequestId;
  final String? workerAvatarUrl;

  const JobTrackingScreen({
    super.key,
    required this.workerName,
    required this.serviceTitle,
    this.jobRequestId,
    this.workerAvatarUrl,
  });

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  static const String _baseUrl = 'https://techni-backend.onrender.com';
  
  bool arrived = false;
  bool workerReadyToStart = false; // worker pressed Start Job, waiting for customer
  bool workStarted = false;
  bool workDone = false;
  bool _isAccepting = false;
  String? _workerId;
  String? _workerBio; // Store worker's bio
  int timerSeconds = 0;
  DateTime? _jobStartedAt;
  Timer? _timer;
  Timer? _syncTimer; // Sync timer with backend every 5 seconds
  StreamSubscription? _jobSub;
  StreamSubscription? _completedJobSub;
  StreamSubscription? _workerProfileSub;
  double? _realFare; // Store the real fare from backend calculation
  String? _workerProfileUrl;

  @override
  void initState() {
    super.initState();
    _listenToJobRequest();
    _listenToCompletedJob(); // Listen for real price from backend
  }

  void _listenToJobRequest() {
    if (widget.jobRequestId == null) return;

    _jobSub?.cancel();
    _jobSub = FirebaseFirestore.instance
        .collection('jobRequests')
        .doc(widget.jobRequestId)
        .snapshots()
        .listen((doc) {
          if (!doc.exists || !mounted) return;
          final data = doc.data()!;
          final status = data['status'];

          debugPrint('JobTrackingScreen: Status changed to $status');

          setState(() {
            arrived = (status == 'arrived' ||
                status == 'workerStartedWork' ||
                status == 'workStarted' ||
                status == 'completed');
            workerReadyToStart = (status == 'workerStartedWork');
            final newWorkerId = data['workerId']?.toString();
            if (newWorkerId != _workerId) {
              _workerId = newWorkerId;
              _listenToWorkerProfile();
            }
            _workerBio = data['workerBio'];
            final url = data['workerProfileUrl']?.toString();
            if (url != null && url.trim().isNotEmpty) {
              _workerProfileUrl = url;
            }

            if (status == 'workStarted') {
              workerReadyToStart = false;
              workStarted = true;
              workDone = false;
              final startedAt = data['jobStartedAt'];
              if (startedAt is Timestamp) {
                _jobStartedAt = startedAt.toDate();
              }
              _resumeTimer();
              _startTimerSync();
            }
          });
        });
  }

  void _listenToWorkerProfile() {
    final wid = _workerId;
    if (wid == null || wid.trim().isEmpty) return;

    _workerProfileSub?.cancel();
    _workerProfileSub = FirebaseFirestore.instance
        .collection('workers')
        .doc(wid)
        .snapshots()
        .listen((doc) {
      if (!mounted || !doc.exists) return;
      final data = doc.data() ?? {};
      final profileUrl = data['profileUrl']?.toString();
      if (profileUrl != null && profileUrl.trim().isNotEmpty) {
        setState(() {
          _workerProfileUrl = profileUrl;
        });
      }
    });
  }

  ImageProvider? _workerAvatarImage() {
    final fromProfile = (_workerProfileUrl ?? '').trim();
    if (fromProfile.isNotEmpty && fromProfile.startsWith('http')) {
      return NetworkImage(fromProfile);
    }
    final fromArg = (widget.workerAvatarUrl ?? '').trim();
    if (fromArg.isNotEmpty && fromArg.startsWith('http')) {
      return NetworkImage(fromArg);
    }
    return null;
  }

  /// Listen to the "completed jobs" collection for real fare from backend
  void _listenToCompletedJob() {
    if (widget.jobRequestId == null) return;

    _completedJobSub?.cancel();
    _completedJobSub = FirebaseFirestore.instance
        .collection('completed jobs')
        .doc(widget.jobRequestId)
        .snapshots()
        .listen((doc) {
          if (!doc.exists || !mounted) return;
          final data = doc.data()!;
          final fare = data['fare'];

          if (fare != null && (fare as num) > 0) {
            final durationSecs = data['durationSeconds'];
            _stopTimer();
            _syncTimer?.cancel();
            setState(() {
              _realFare = fare.toDouble();
              workStarted = true;
              workDone = true;
              if (durationSecs != null) {
                timerSeconds = (durationSecs as num).toInt();
              }
            });
            debugPrint('JobTrackingScreen: Job complete. Fare: $_realFare');
          }
        });
  }

  /// Start syncing timer with backend every 5 seconds to keep timers in sync
  void _startTimerSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (mounted && (workStarted && !workDone)) {
        _syncTimerWithBackend();
      }
    });
  }

  Future<void> _syncTimerWithBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/job/${widget.jobRequestId}/elapsed-time'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final backendElapsedSeconds = data['elapsedSeconds'] ?? 0;
          // Sync local timer with backend if difference is > 2 seconds
          if ((timerSeconds - backendElapsedSeconds).abs() > 2) {
            setState(() {
              timerSeconds = backendElapsedSeconds;
              debugPrint('[TIMER_SYNC] Customer synced with backend: $timerSeconds seconds');
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[TIMER_SYNC_CUSTOMER] Error: $e');
    }
  }

  void _resumeTimer() {
    if (_timer != null) return; // Already running

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_jobStartedAt != null && mounted) {
        setState(() {
          timerSeconds = math.max(
            0,
            DateTime.now().difference(_jobStartedAt!).inSeconds,
          );
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Customer accepts the worker's start request → backend sets workStarted + jobStartedAt
  Future<void> _acceptStart() async {
    if (_isAccepting || widget.jobRequestId == null) return;
    setState(() => _isAccepting = true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/job/confirm-start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'jobId': widget.jobRequestId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && mounted) {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] ?? 'Failed to accept')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error — check backend')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel();
    _jobSub?.cancel();
    _completedJobSub?.cancel();
    _workerProfileSub?.cancel();
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
      floatingActionButton: !workDone
          ? FloatingActionButton(
              heroTag: 'jobTrackingEmergencyFab',
              backgroundColor: const Color(0xFFFF2A2A),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmergencyHelpScreen(
                      serviceTitle: widget.serviceTitle,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _workerInfoCard(),
            const SizedBox(height: 24),
            _statusSection(),
            const SizedBox(height: 32),
            if (arrived && !workerReadyToStart && !workStarted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _actionButton('Call Worker', _callWorker, Colors.orange),
                ],
              )
            else if (workerReadyToStart)
              _acceptStartCard()
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
    final avatarImage = _workerAvatarImage();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? const Icon(Icons.person, size: 40, color: Colors.blue)
                : null,
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
          // Display worker bio if available
          if (_workerBio != null && _workerBio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _workerBio!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade400,
            size: 20,
          ),
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
            style: TextStyle(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(timerSeconds),
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Worker is currently working...',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Timer will stop when worker ends the job.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _acceptStartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.notifications_active, color: Colors.blue, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Worker is ready to start!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap Accept to start the job and the timer.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _actionButton('Call Worker', _callWorker, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isAccepting ? null : _acceptStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isAccepting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Accept Start',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
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
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _summarySection() {
    final finalPrice = _realFare;
    
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          _summaryRow('Duration', _formatTime(timerSeconds)),
          const Divider(),
          _summaryRow(
            'Total Price',
            finalPrice != null
                ? 'Rs. ${finalPrice.toStringAsFixed(0)}'
                : 'Calculating...',
            subtitle: finalPrice != null ? '(Final Amount)' : null,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (widget.jobRequestId != null && _workerId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(
                      jobId: widget.jobRequestId!,
                      workerId: _workerId!,
                      workerName: widget.workerName,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Pay & Close',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Call worker when they're on the way
  Future<void> _callWorker() async {
    try {
      String? workerPhone;
      
      if (widget.jobRequestId != null) {
        final jobDoc = await FirebaseFirestore.instance
            .collection('jobRequests')
            .doc(widget.jobRequestId)
            .get();

        if (jobDoc.exists) {
          final data = jobDoc.data()!;
          workerPhone = (data['workerPhone'] ?? data['workerPhoneNumber'])
              ?.toString()
              .trim();
        }
      }

      final workerId = _workerId;
      if ((workerPhone == null || workerPhone.isEmpty) &&
          workerId != null &&
          workerId.isNotEmpty) {
        final workerDoc = await FirebaseFirestore.instance
            .collection('workers')
            .doc(workerId)
            .get();

        if (workerDoc.exists) {
          final workerData = workerDoc.data()!;
          workerPhone = (workerData['phoneNumber'] ??
                  workerData['workerPhone'] ??
                  workerData['workerPhoneNumber'])
              ?.toString()
              .trim();
        }
      }

      if (workerPhone == null || workerPhone.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Worker phone number not available'),
            ),
          );
        }
        return;
      }

      final url = Uri.parse('tel:$workerPhone');
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open phone dialer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calling worker: $e')),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return seconds >= 3600 ? '$h:$m:$s' : '$m:$s';
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
