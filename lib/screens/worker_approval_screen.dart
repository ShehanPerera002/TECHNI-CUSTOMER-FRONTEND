import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/booking_service.dart';
import '../models/professional.dart';
import '../models/professional_profile_data.dart';
import '../models/review.dart';
import 'worker_on_the_way_screen.dart';

/// Screen shown after a worker accepts the job request.
/// Customer reviews the worker's profile and decides to confirm or decline.
class WorkerApprovalScreen extends StatefulWidget {
  final Professional professional;
  final String serviceTitle;

  const WorkerApprovalScreen({
    super.key,
    required this.professional,
    required this.serviceTitle,
  });

  @override
  State<WorkerApprovalScreen> createState() => _WorkerApprovalScreenState();
}

class _WorkerApprovalScreenState extends State<WorkerApprovalScreen> {
  List<Review> _reviews = [];
  bool _reviewsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final json = await rootBundle.loadString(
        'assets/data/professional_reviews.json',
      );
      final map = jsonDecode(json) as Map<String, dynamic>;
      final list = map[widget.professional.id] as List<dynamic>?;
      if (list != null) {
        setState(() {
          _reviews = list
              .map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList();
          _reviewsLoaded = true;
        });
      } else {
        setState(() => _reviewsLoaded = true);
      }
    } catch (e) {
      setState(() => _reviewsLoaded = true);
    }
  }

  void _confirmWorker() {
    // Save the real-time booking
    BookingService.instance.addRealTimeBooking(
      serviceTitle: widget.serviceTitle,
      worker: widget.professional,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => WorkerOnTheWayScreen(
          professional: widget.professional,
          serviceTitle: widget.serviceTitle,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _declineWorker() {
    // Go back to previous screen (connecting/find professional)
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.professional;
    final profile = ProfessionalProfileData.getForProfessional(p.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Worker Found',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF22C55E),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${p.name} accepted your request! Review their profile below.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Worker header
                  _buildWorkerHeader(p),
                  const SizedBox(height: 20),
                  // Verified section
                  _buildVerifiedSection(profile),
                  const SizedBox(height: 16),
                  // Personal details
                  _buildPersonalDetails(profile),
                  const SizedBox(height: 16),
                  // Description
                  _buildDescription(profile),
                  const SizedBox(height: 16),
                  // Reviews
                  _buildReviewsSection(p),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Bottom action bar
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildWorkerHeader(Professional p) {
    return Row(
      children: [
        CircleAvatar(radius: 40, backgroundImage: NetworkImage(p.avatarUrl)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < p.rating.floor() ? Icons.star : Icons.star_border,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${p.rating}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    p.phoneNumber,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Can arrive in ${p.timeToBook}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedSection(ProfessionalProfileData profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Verified by Techni',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.verified, size: 18, color: Colors.blue.shade700),
            ],
          ),
          const SizedBox(height: 10),
          ...profile.verifiedServices.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(ProfessionalProfileData profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _detailRow(Icons.location_on, 'From', profile.from),
          const SizedBox(height: 10),
          _detailRow(Icons.school, 'Qualifications', profile.qualifications),
          const SizedBox(height: 10),
          _detailRow(Icons.schedule, 'Avg. Response', profile.avgResponseTime),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ProfessionalProfileData profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Professional p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                '${p.rating}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_reviewsLoaded)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reviews.isEmpty)
            Text(
              'No reviews yet.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            )
          else
            ..._reviews.take(3).map((r) => _buildReviewCard(r)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, backgroundImage: NetworkImage(r.avatarUrl)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < r.rating.floor() ? Icons.star : Icons.star_border,
                        size: 12,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  r.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  r.customerName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confirm & Decline row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _confirmWorker,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _declineWorker,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
