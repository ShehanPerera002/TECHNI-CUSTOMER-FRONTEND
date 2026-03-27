import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  final String jobId;
  final String workerId;
  final String workerName;

  const FeedbackScreen({
    super.key,
    required this.jobId,
    required this.workerId,
    required this.workerName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const String _baseUrl = 'https://techni-backend.onrender.com';
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String reviewerName = user?.displayName?.trim() ?? '';

      if (reviewerName.isEmpty && user?.uid != null) {
        final customerDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user!.uid)
            .get();
        if (customerDoc.exists) {
          final data = customerDoc.data() ?? {};
          reviewerName =
              (data['name'] ?? data['fullName'] ?? '').toString().trim();
        }
      }

      if (reviewerName.isEmpty) {
        reviewerName = 'Customer';
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/job/submit-review'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'jobId': widget.jobId,
              'workerId': widget.workerId,
              'rating': _rating,
              'comment': _commentController.text.trim(),
              'reviewerName': reviewerName,
              'reviewerId': user?.uid,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        String message = 'Failed to submit feedback';
        try {
          final data = jsonDecode(response.body);
          message = data['error'] ?? message;
        } catch (_) {}
        throw Exception(message);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              'How was your work with\n${widget.workerName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your rating',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
