import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/professional.dart';
import '../models/job_request.dart';
import 'worker_approval_screen.dart';

class ConnectingWorkerScreen extends StatefulWidget {
  final List<Professional> professionals;
  final String serviceTitle;
  final String? jobRequestId;

  const ConnectingWorkerScreen({
    super.key,
    required this.professionals,
    required this.serviceTitle,
    this.jobRequestId,
  });

  @override
  State<ConnectingWorkerScreen> createState() => _ConnectingWorkerScreenState();
}

class _ConnectingWorkerScreenState extends State<ConnectingWorkerScreen> {
  Timer? _progressTimer;
  StreamSubscription<DocumentSnapshot>? _jobSubscription;
  double _progress = 0.0;
  late Professional _assignedProfessional;
  late List<Professional> _remainingProfessionals;

  @override
  void initState() {
    super.initState();
    _remainingProfessionals = List.from(widget.professionals);
    _startSearching();
  }

  void _startSearching() {
    _progress = 0.0;
    if (_remainingProfessionals.isEmpty) {
      // No workers left
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No more workers available. Please try again later.'),
          ),
        );
        Navigator.of(context).pop();
      });
      return;
    }

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      // Loop visual progress up to 90%
      if (_progress < 0.9) {
        setState(() => _progress = (_progress + 0.05).clamp(0.0, 0.9));
      }
    });

    if (widget.jobRequestId != null) {
      _listenToJobRequest();
    } else {
      // Fallback mock flow
      final random = Random();
      final index = random.nextInt(_remainingProfessionals.length);
      _assignedProfessional = _remainingProfessionals[index];
      _remainingProfessionals.removeAt(index);
      
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _progressTimer?.cancel();
        setState(() => _progress = 1.0);
        _showApprovalScreen();
      });
    }
  }

  void _listenToJobRequest() {
    _jobSubscription?.cancel();
    _jobSubscription = FirebaseFirestore.instance
        .collection('jobRequests')
        .doc(widget.jobRequestId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;
      
      final jobReq = JobRequest.fromFirestore(snapshot);
      if (jobReq.status == 'workerFound' && jobReq.workerId != null) {
        _jobSubscription?.cancel();
        _progressTimer?.cancel();
        if (!mounted) return;
        setState(() => _progress = 1.0);
        
        // Fetch real worker details
        try {
          final workerDoc = await FirebaseFirestore.instance.collection('workers').doc(jobReq.workerId).get();
          if (workerDoc.exists && mounted) {
            _assignedProfessional = Professional.fromFirestore(workerDoc);
            _showApprovalScreen();
            return;
          }
        } catch (e) {
          debugPrint('Error fetching assigned worker: $e');
        }
        
        // Fallback to _professionals list if fetching fails
        if (mounted) {
          _assignedProfessional = widget.professionals.firstWhere(
            (p) => p.id == jobReq.workerId,
            orElse: () => widget.professionals.first,
          );
          _showApprovalScreen();
        }
      }
    });
  }

  Future<void> _showApprovalScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkerApprovalScreen(
          professional: _assignedProfessional,
          serviceTitle: widget.serviceTitle,
          jobRequestId: widget.jobRequestId,
        ),
      ),
    );

    // If declined (popped with false), search for next worker
    if (result == false && mounted) {
      if (widget.jobRequestId != null) {
        // Reset status to searching for other workers to accept
        await FirebaseFirestore.instance.collection('jobRequests').doc(widget.jobRequestId).update({
          'status': 'searching',
          'workerId': FieldValue.delete(),
        });
      }
      setState(() => _startSearching());
    }
    // If confirmed/scheduled, the approval screen navigates via
    // pushAndRemoveUntil, which disposes this screen automatically.
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _jobSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Searching...',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Looking for the first available worker\nto accept your request',
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
                  onPressed: () {
                    if (widget.jobRequestId != null) {
                      FirebaseFirestore.instance.collection('jobRequests').doc(widget.jobRequestId).update({
                        'status': 'cancelled',
                        'cancelReason': 'Customer cancelled',
                      });
                    }
                    Navigator.of(context).pop();
                  },
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
