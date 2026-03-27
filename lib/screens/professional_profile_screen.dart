import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../models/professional_profile_data.dart';
import '../models/review.dart';

/// Full profile screen for a selected professional.
class ProfessionalProfileScreen extends StatefulWidget {
  final Professional professional;
  final String serviceTitle;

  const ProfessionalProfileScreen({
    super.key,
    required this.professional,
    required this.serviceTitle,
  });

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  List<Review> _reviews = [];
  bool _reviewsLoaded = false;
  double? _workerAverageRating;
  int? _workerReviewCount;

  @override
  void initState() {
    super.initState();
    _loadWorkerRatingSummary();
    _loadReviews();
  }

  Future<void> _loadWorkerRatingSummary() async {
    try {
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.professional.id)
          .get();

      if (!workerDoc.exists || !mounted) return;

      final data = workerDoc.data() ?? {};
      setState(() {
        _workerAverageRating = (data['averageRating'] as num?)?.toDouble();
        _workerReviewCount = (data['ratingCount'] as num?)?.toInt();
      });
    } catch (_) {
      // Keep existing model values when aggregate lookup fails.
    }
  }

  Future<void> _loadReviews() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.professional.id)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (!mounted) return;
      setState(() {
        _reviews = snap.docs
            .map((doc) => Review.fromFirestore(doc.data()))
            .toList();
        _reviewsLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading worker reviews: $e');
      setState(() => _reviewsLoaded = true);
    }
  }

  double get _displayRating {
    return _workerAverageRating ?? widget.professional.rating;
  }

  int get _displayReviewCount {
    return _workerReviewCount ?? widget.professional.reviewCount;
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
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(p),
            const SizedBox(height: 24),
            _buildVerifiedSection(profile),
            const SizedBox(height: 20),
            _buildPersonalDetails(profile),
            const SizedBox(height: 20),
            _buildDescription(profile),
            const SizedBox(height: 20),
            _buildReviewsSection(p),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Professional p) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage(p.avatarUrl),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.build, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          p.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (i) => Icon(
                i < _displayRating.floor() ? Icons.star : Icons.star_border,
                size: 20,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_displayRating.toStringAsFixed(1)} ($_displayReviewCount reviews)',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifiedSection(ProfessionalProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Verified by Techni',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.verified, size: 18, color: Colors.blue.shade700),
          ],
        ),
        const SizedBox(height: 12),
        ...profile.verifiedServices.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetails(ProfessionalProfileData profile) {
    return Column(
      children: [
        _detailRow(Icons.location_on, 'From', profile.from),
        const SizedBox(height: 12),
        _detailRow(Icons.school, 'Qualifications', profile.qualifications),
        const SizedBox(height: 12),
        _detailRow(
          Icons.schedule,
          'Avg. Response Time',
          profile.avgResponseTime,
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ProfessionalProfileData profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.description,
            style: TextStyle(
              fontSize: 14,
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                '${_displayRating.toStringAsFixed(1)} ($_displayReviewCount reviews)',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            )
          else
            ..._reviews.map((r) => _buildReviewCard(r)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review r) {
    final hasAvatar = r.avatarUrl.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: hasAvatar ? NetworkImage(r.avatarUrl) : null,
            child: hasAvatar ? null : const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
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
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  r.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r.customerName,
                  style: TextStyle(
                    fontSize: 12,
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
}
