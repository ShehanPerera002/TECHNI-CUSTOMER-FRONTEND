import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/professional.dart';
import '../models/professional_profile_data.dart';
import '../models/review.dart';

/// Full profile screen for a selected professional.
class ProfessionalProfileScreen extends StatefulWidget {
  final Professional professional;

  const ProfessionalProfileScreen({
    super.key,
    required this.professional,
  });

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  List<Review> _reviews = [];
  bool _reviewsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final json =
          await rootBundle.loadString('assets/data/professional_reviews.json');
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
            ...List.generate(5, (i) => Icon(
                  i < p.rating.floor() ? Icons.star : Icons.star_border,
                  size: 20,
                  color: Colors.amber.shade700,
                )),
            const SizedBox(width: 6),
            Text(
              '${p.rating} (247 reviews)',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text(
                    'Connect Now',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: const Text(
                    'Schedule',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black87),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
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
                Icon(Icons.check_circle, size: 20, color: Colors.green.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
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
        _detailRow(Icons.schedule, 'Avg. Response Time', profile.avgResponseTime),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
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
                '${p.rating} (${_reviews.length} reviews)',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_reviewsLoaded)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()))
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(r.avatarUrl),
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
                        i < r.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
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
