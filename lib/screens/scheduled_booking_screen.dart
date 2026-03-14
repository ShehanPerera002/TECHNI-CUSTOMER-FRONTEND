import 'package:flutter/material.dart';

import '../core/booking_service.dart';
import '../models/professional.dart';

/// Confirmation screen shown after a customer schedules a worker.
class ScheduledBookingScreen extends StatefulWidget {
  final String serviceTitle;
  final String scheduledDate;
  final String scheduledTime;
  final List<Professional> availableWorkers;

  const ScheduledBookingScreen({
    super.key,
    required this.serviceTitle,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.availableWorkers,
  });

  @override
  State<ScheduledBookingScreen> createState() =>
      _ScheduledBookingScreenState();
}

class _ScheduledBookingScreenState extends State<ScheduledBookingScreen> {
  @override
  void initState() {
    super.initState();
    // Save the scheduled booking
    BookingService.instance.addScheduledBooking(
      serviceTitle: widget.serviceTitle,
      scheduledDate: widget.scheduledDate,
      scheduledTime: widget.scheduledTime,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Booking Confirmed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF22C55E),
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Scheduled!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your service has been scheduled successfully.\nA worker will be assigned on the scheduled date.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Booking details card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.home_repair_service,
                      label: 'Service',
                      value: widget.serviceTitle,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: widget.scheduledDate,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: widget.scheduledTime,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: 'Pending',
                      valueColor: const Color(0xFFF59E0B),
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.people_outline,
                      label: 'Available Workers',
                      value: '${widget.availableWorkers.length} nearby',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Workers preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.group, size: 18, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text(
                          'Workers in your area',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.availableWorkers.length,
                        itemBuilder: (context, index) {
                          final w = widget.availableWorkers[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(w.avatarUrl),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  w.name.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The first available worker will be assigned to your booking on the scheduled date.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // What happens next
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What happens next?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StepItem(
                      number: '1',
                      text: 'Your booking request is sent to nearby workers',
                    ),
                    _StepItem(
                      number: '2',
                      text: 'The first worker to accept will be assigned',
                    ),
                    _StepItem(
                      number: '3',
                      text: 'You\'ll be notified once a worker is confirmed',
                    ),
                    _StepItem(
                      number: '4',
                      text: 'Review the worker\'s profile before they arrive',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Another Service',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
