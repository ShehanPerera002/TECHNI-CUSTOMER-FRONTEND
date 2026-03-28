import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../models/booking.dart';
import '../models/professional.dart';
import 'job_tracking_screen.dart';
import 'worker_approval_screen.dart';
import 'worker_on_the_way_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final customerIds = _customerIds(user);
    if (customerIds.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar([], [], []),
        body: const Center(child: Text('Please sign in to view bookings.')),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobRequests')
          .where('customerId', whereIn: customerIds)
          .snapshots(),
      builder: (context, jobsSnapshot) {
        if (jobsSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar([], [], []),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('completed jobs')
              .where('customerId', whereIn: customerIds)
              .snapshots(),
          builder: (context, completedSnapshot) {
            if (completedSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: _buildAppBar([], [], []),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scheduledJobs')
                  .where('customerId', whereIn: customerIds)
                  .snapshots(),
              builder: (context, scheduledSnapshot) {
                final mergedById = <String, Booking>{};

                if (jobsSnapshot.hasData) {
                  for (final doc in jobsSnapshot.data!.docs) {
                    final booking = _docToBooking(doc);
                    mergedById[booking.id] = booking;
                  }
                }

                if (completedSnapshot.hasData) {
                  for (final doc in completedSnapshot.data!.docs) {
                    final booking = _docToBooking(doc, forceCompleted: true);
                    // Completed collection is source of truth after completion.
                    mergedById[booking.id] = booking;
                  }
                }

                if (scheduledSnapshot.hasData) {
                  for (final doc in scheduledSnapshot.data!.docs) {
                    final booking = _scheduledDocToBooking(doc);
                    mergedById['sched_${booking.id}'] = booking;
                  }
                }

                final allBookings = mergedById.values.toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                final upcoming = allBookings
                    .where((b) =>
                        b.status == BookingStatus.pending ||
                        b.status == BookingStatus.confirmed ||
                        b.status == BookingStatus.inProgress)
                    .toList();
                final completed = allBookings
                    .where((b) => b.status == BookingStatus.completed)
                    .toList();
                final cancelled = allBookings
                    .where((b) => b.status == BookingStatus.cancelled)
                    .toList();

                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: _buildAppBar(upcoming, completed, cancelled),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _BookingList(bookings: upcoming, emptyMessage: 'No upcoming bookings'),
                      _BookingList(bookings: completed, emptyMessage: 'No completed bookings'),
                      _BookingList(bookings: cancelled, emptyMessage: 'No cancelled bookings'),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<String> _customerIds(User? user) {
    final ids = <String>{};
    final uid = user?.uid;
    final sessionId = SessionManager.customerDocId;

    if (uid != null && uid.trim().isNotEmpty) {
      ids.add(uid);
    }
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      ids.add(sessionId);
    }

    return ids.toList();
  }

  PreferredSizeWidget _buildAppBar(
    List<Booking> upcoming,
    List<Booking> completed,
    List<Booking> cancelled,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'My Bookings',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          Tab(text: 'Upcoming (${upcoming.length})'),
          Tab(text: 'Completed (${completed.length})'),
          Tab(text: 'Cancelled (${cancelled.length})'),
        ],
      ),
    );
  }

  static Booking _docToBooking(DocumentSnapshot doc, {bool forceCompleted = false}) {
    final raw = doc.data();
    if (raw is! Map<String, dynamic>) {
      return Booking(
        id: doc.id,
        serviceTitle: 'Service',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );
    }

    final data = raw;
    final status = forceCompleted
        ? BookingStatus.completed
        : _mapStatus(data['status'] as String? ?? '');
    final ts = status == BookingStatus.completed
        ? (data['completedAt'] ?? data['updatedAt'] ?? data['createdAt'])
        : status == BookingStatus.cancelled
            ? (data['cancelledAt'] ?? data['updatedAt'] ?? data['createdAt'])
            : (data['updatedAt'] ?? data['createdAt']);
    final createdAt = ts is Timestamp ? ts.toDate() : DateTime.now();
    return Booking(
      id: doc.id,
      serviceTitle:
          (data['jobType'] ?? data['serviceTitle'] ?? data['category_name'] ?? 'Service') as String,
      type: BookingType.realTime,
      status: status,
      createdAt: createdAt,
      workerName: data['workerName'] as String?,
      fare: (data['fare'] as num?)?.toDouble(),
    );
  }

  static Booking _scheduledDocToBooking(DocumentSnapshot doc) {
    final raw = doc.data();
    if (raw is! Map<String, dynamic>) {
      return Booking(
        id: doc.id,
        serviceTitle: 'Scheduled Service',
        type: BookingType.scheduled,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );
    }
    final data = raw;
    final statusStr = data['status'] as String? ?? 'pending';
    BookingStatus schedStatus;
    switch (statusStr) {
      case 'accepted':
        schedStatus = BookingStatus.confirmed;
        break;
      case 'completed':
        schedStatus = BookingStatus.completed;
        break;
      case 'cancelled':
      case 'noWorkersFound':
        schedStatus = BookingStatus.cancelled;
        break;
      default:
        schedStatus = BookingStatus.pending;
    }
    final createdAtTs = data['createdAt'];
    final createdAt =
        createdAtTs is Timestamp ? createdAtTs.toDate() : DateTime.now();
    return Booking(
      id: doc.id,
      serviceTitle: (data['serviceTitle'] ?? 'Service').toString(),
      type: BookingType.scheduled,
      status: schedStatus,
      createdAt: createdAt,
      workerName: data['workerName'] as String?,
    );
  }

  static BookingStatus _mapStatus(String s) {
    final normalized = s.trim().toLowerCase();
    switch (normalized) {
      case 'searching':
      case 'pending':
        return BookingStatus.pending;
      case 'workerfound':
      case 'customerconfirmed':
      case 'accepted':
      case 'arrived':
      case 'assigned':
        return BookingStatus.confirmed;
      case 'inprogress':
      case 'workerstartedwork':
      case 'workstarted':
        return BookingStatus.inProgress;
      case 'completed':
      case 'done':
      case 'finished':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
      case 'declined':
      case 'failed':
      case 'expired':
      case 'timeout':
      case 'timedout':
      case 'no_worker_found':
      case 'noworkerfound':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyMessage;

  const _BookingList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isScheduled = booking.type == BookingType.scheduled;
    final statusColor = _statusColor(booking.status);
    final statusLabel = _statusLabel(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: service + status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _serviceIcon(booking.serviceTitle),
                    color: const Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isScheduled ? 'Scheduled' : 'Real-time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (isScheduled && booking.scheduledDate != null) ...[
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: booking.scheduledDate!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (isScheduled && booking.scheduledTime != null) ...[
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: booking.scheduledTime!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (!isScheduled) ...[
                    _InfoRow(
                      icon: Icons.flash_on,
                      label: 'Type',
                      value: 'Instant Booking',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: _formatDate(booking.createdAt),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _InfoRow(
                    icon: Icons.receipt_long,
                    label: 'Booking ID',
                    value: booking.id,
                  ),
                  if (booking.fare != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Fare',
                      value: 'Rs ${booking.fare!.toStringAsFixed(0)}',
                    ),
                  ],
                ],
              ),
            ),
            // Worker info
            if (booking.workerName != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: booking.workerAvatarUrl != null
                        ? NetworkImage(booking.workerAvatarUrl!)
                        : null,
                    child: booking.workerAvatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.workerName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (booking.workerRating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                booking.workerRating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Assigned Worker',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
            if (booking.workerName == null && isScheduled) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.person_search,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Worker will be assigned on scheduled date',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
            // Action buttons: Cancel for pending, Track for confirmed
            if (isScheduled) ...[
              const SizedBox(height: 16),
              _ScheduledBookingActions(
                booking: booking,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return const Color(0xFF2563EB);
      case BookingStatus.inProgress:
        return const Color(0xFF8B5CF6);
      case BookingStatus.completed:
        return const Color(0xFF22C55E);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _serviceIcon(String title) {
    if (title.contains('Plumb')) return Icons.plumbing;
    if (title.contains('Electr')) return Icons.electrical_services;
    if (title.contains('Garden')) return Icons.yard;
    if (title.contains('Carpen')) return Icons.carpenter;
    if (title.contains('Paint')) return Icons.format_paint;
    if (title.contains('AC')) return Icons.ac_unit;
    if (title.contains('ELV')) return Icons.settings_input_antenna;
    return Icons.home_repair_service;
  }
}

/// Scheduled booking action widget: Cancel (pending) or Track (confirmed)
class _ScheduledBookingActions extends StatefulWidget {
  final Booking booking;

  const _ScheduledBookingActions({
    required this.booking,
  });

  @override
  State<_ScheduledBookingActions> createState() => _ScheduledBookingActionsState();
}

class _ScheduledBookingActionsState extends State<_ScheduledBookingActions> {
  StreamSubscription? _jobSub;
  bool _accepted = false;
  bool _noWorkersFound = false;
  bool _navigated = false;
  String? _jobRequestId;
  String? _workerName;
  String? _workerAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Listen for released job matching this scheduled booking
    _listenForReleasedJob();
      // Also listen to the scheduled job itself for noWorkersFound status
      _listenToScheduledStatus();
  }

    void _listenToScheduledStatus() {
      FirebaseFirestore.instance
          .collection('scheduledJobs')
          .doc(widget.booking.id)
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        final status = snap.data()?['status'] as String? ?? '';
        if (status == 'noWorkersFound') {
          setState(() {
            _noWorkersFound = true;
          });
        }
      });
    }

  void _listenForReleasedJob() {
    _jobSub = FirebaseFirestore.instance
        .collection('jobRequests')
        .where('fromScheduledJobId', isEqualTo: widget.booking.id)
        .snapshots()
        .listen((snap) async {
      if (!mounted || snap.docs.isEmpty) return;

      final doc = snap.docs.first;
      final data = doc.data();
      final status = (data['status'] as String? ?? '').trim();
      final workerId = data['workerId'] as String?;
      final jobId = doc.id;

      // ── Worker just accepted → show WorkerApprovalScreen ──────────────
      if (status == 'workerFound' && workerId != null && !_navigated) {
        _navigated = true;
        _jobSub?.cancel();
        setState(() {
          _jobRequestId = jobId;
          _workerName = data['workerName'] as String?;
          _workerAvatarUrl = data['workerAvatarUrl'] as String?;
        });
        try {
          final workerDoc = await FirebaseFirestore.instance
              .collection('workers').doc(workerId).get();
          if (!mounted) return;
          final professional = Professional.fromFirestore(workerDoc);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WorkerApprovalScreen(
                professional: professional,
                serviceTitle: widget.booking.serviceTitle,
                jobRequestId: jobId,
              ),
            )).then((_) {
              if (mounted) setState(() => _navigated = false);
            });
          });
        } catch (e) {
          debugPrint('[ScheduledFlow] Error fetching worker on workerFound: $e');
          if (mounted) setState(() => _navigated = false);
        }
        return;
      }

      // ── Customer confirmed → show WorkerOnTheWayScreen (map + live location) ─
      if ((status == 'customerConfirmed' || status == 'inProgress') &&
          workerId != null && !_navigated) {
        _navigated = true;
        _jobSub?.cancel();
        setState(() {
          _accepted = true;
          _jobRequestId = jobId;
          _workerName = data['workerName'] as String?;
          _workerAvatarUrl = data['workerAvatarUrl'] as String?;
        });
        try {
          final workerDoc = await FirebaseFirestore.instance
              .collection('workers').doc(workerId).get();
          if (!mounted) return;
          final professional = Professional.fromFirestore(workerDoc);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WorkerOnTheWayScreen(
                professional: professional,
                serviceTitle: widget.booking.serviceTitle,
                jobRequestId: jobId,
              ),
            )).then((_) {
              if (mounted) setState(() => _navigated = false);
            });
          });
        } catch (e) {
          debugPrint('[ScheduledFlow] Error fetching worker on customerConfirmed: $e');
          if (mounted) setState(() => _navigated = false);
        }
        return;
      }

      // ── Already arrived / working → go straight to tracking/timer ──────
      if ((status == 'arrived' || status == 'workerStartedWork' ||
           status == 'workStarted' || status == 'completed') && !_navigated) {
        _navigated = true;
        _jobSub?.cancel();
        final name = (data['workerName'] as String?) ?? '';
        final avatar = data['workerAvatarUrl'] as String?;
        setState(() {
          _accepted = true;
          _jobRequestId = jobId;
          _workerName = name;
          _workerAvatarUrl = avatar;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => JobTrackingScreen(
              jobRequestId: jobId,
              workerName: name,
              serviceTitle: widget.booking.serviceTitle,
              workerAvatarUrl: avatar,
            ),
          )).then((_) {
            if (mounted) setState(() => _navigated = false);
          });
        });
      }
    });
  }

  Future<void> _cancelScheduledBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'Are you sure you want to cancel this ${widget.booking.serviceTitle} booking scheduled for ${widget.booking.scheduledDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('scheduledJobs')
          .doc(widget.booking.id)
          .update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToTimer() {
    if (_jobRequestId == null || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JobTrackingScreen(
        jobRequestId: _jobRequestId!,
        workerName: _workerName ?? '',
        serviceTitle: widget.booking.serviceTitle,
        workerAvatarUrl: _workerAvatarUrl,
      ),
    ));
  }

  @override
  void dispose() {
    _jobSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_noWorkersFound) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No workers were available at your scheduled time. Please reschedule or try booking a different date.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // Navigate back to find_professional_screen to reschedule
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Reschedule Booking',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_accepted) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _navigateToTimer,
          icon: const Icon(Icons.map, size: 18),
          label: const Text(
            'View Tracking',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Show cancel button for pending scheduled bookings
    if (widget.booking.status == BookingStatus.pending) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _cancelScheduledBooking,
          icon: const Icon(Icons.close, size: 18),
          label: const Text(
            'Cancel Booking',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade500,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
