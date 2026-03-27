import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../core/cloudinary_service.dart';
import '../core/session_manager.dart';
import '../models/professional.dart';
import '../models/job_request.dart';
import 'connecting_worker_screen.dart';
import 'scheduled_booking_screen.dart';

/// Screen showing map with available professionals and booking options.
class FindProfessionalScreen extends StatefulWidget {
  final String serviceTitle;
  final String? issueDescription;
  final File? issueImageFile;

  const FindProfessionalScreen({
    super.key,
    required this.serviceTitle,
    this.issueDescription,
    this.issueImageFile,
  });

  @override
  State<FindProfessionalScreen> createState() => _FindProfessionalScreenState();
}

class _FindProfessionalScreenState extends State<FindProfessionalScreen> {
  static const _baseUrl = 'https://techni-backend.onrender.com';
  static const _userLocation = LatLng(6.9271, 79.8612);
  List<Professional> _professionals = [];
  bool _isLoadingWorkers = true;
  // final String _paymentMethod = 'Cash'; // Removed unused field
  String _language = 'Sinhala';
  Timer? _movementTimer;
  final Random _random = Random();
  static const _movingIndices = [0, 2]; // Saman & Kamala get live movement
  static const _timeOptions = [
    '10 min',
    '12 min',
    '15 min',
    '18 min',
    '20 min',
  ];

  bool _cashOnlySelected = false;

  static const _languageOptions = ['Sinhala', 'English', 'Tamil'];

  GoogleMapController? _mapController;
  LatLng _customerLatLng = _userLocation;

  String _normalizeCategory(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _serviceToWorkerCategory(String serviceTitle) {
    final key = _normalizeCategory(serviceTitle);
    const map = {
      'plumbing_services': 'plumber',
      'plumbing': 'plumber',
      'plumber': 'plumber',
      'electrical_services': 'electrician',
      'electrical': 'electrician',
      'electrician': 'electrician',
      'gardening_services': 'gardener',
      'carpentry_services': 'carpenter',
      'painting_services': 'painter',
      'ac_services': 'ac_tech',
      'elv_services': 'elv_repair',
      'ac_technician': 'ac_tech',
      'ac_repair': 'ac_tech',
      'ac_tech': 'ac_tech',
      'carpentry': 'carpenter',
      'carpenter': 'carpenter',
      'painting': 'painter',
      'painter': 'painter',
      'gardening': 'gardener',
      'gardener': 'gardener',
      'elv_repairer': 'elv_repair',
      'elv_repair': 'elv_repair',
    };
    return map[key] ?? key;
  }

  bool _isCategoryMatch(String? workerCategory, String serviceTitle) {
    if (workerCategory == null || workerCategory.trim().isEmpty) return false;
    final workerKey = _normalizeCategory(workerCategory);
    final expectedKey = _serviceToWorkerCategory(serviceTitle);
    return workerKey == expectedKey;
  }

  TimeOfDay? _parseTimeOfDay(String input) {
    final value = input.trim().toUpperCase();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*([AP]M)$').firstMatch(value);
    if (match == null) return null;

    final hourRaw = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final amPm = match.group(3);
    if (hourRaw == null || minute == null || amPm == null) return null;
    if (hourRaw < 1 || hourRaw > 12 || minute < 0 || minute > 59) return null;

    var hour24 = hourRaw % 12;
    if (amPm == 'PM') hour24 += 12;
    return TimeOfDay(hour: hour24, minute: minute);
  }

  DateTime _resolveScheduledFor(DateTime pickedDate, String selectedTime) {
    final lowered = selectedTime.trim().toLowerCase();
    final minMatch = RegExp(r'^(\d+)\s*min').firstMatch(lowered);
    if (minMatch != null) {
      final mins = int.tryParse(minMatch.group(1) ?? '0') ?? 0;
      return DateTime.now().add(Duration(minutes: mins));
    }

    final tod = _parseTimeOfDay(selectedTime);
    if (tod != null) {
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        tod.hour,
        tod.minute,
      );
    }

    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 9, 0);
  }

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
    _initCustomerLocation();
    _startLiveMovement();
  }

  Future<void> _fetchWorkers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .where('isAvailable', isEqualTo: true)
          .get();
          
      final List<Professional> workers = [];
      for (var doc in snapshot.docs) {
        final p = Professional.fromFirestore(doc);
        if (_isCategoryMatch(p.category, widget.serviceTitle)) {
          workers.add(p);
        }
      }
      
      if (mounted) {
        setState(() {
          _professionals = workers;
          _isLoadingWorkers = false;
          _startLiveMovement(); // Start moving workers after loading
        });
      }
    } catch (e) {
      debugPrint('Error fetching workers: $e');
      if (mounted) {
        setState(() {
          _isLoadingWorkers = false;
        });
      }
    }
  }

  Future<void> _initCustomerLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    setState(() {
      _customerLatLng = LatLng(pos.latitude, pos.longitude);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_customerLatLng));
  }

  void _startLiveMovement() {
    _movementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _professionals.isEmpty) {
        timer.cancel();
        return;
      }

      setState(() {
        for (int idx in _movingIndices) {
          if (idx < _professionals.length) {
            final current = _professionals[idx];
            // Simulate small random movements (±0.0005 degrees)
            final newLat = current.location.latitude + (_random.nextDouble() - 0.5) * 0.001;
            final newLng = current.location.longitude + (_random.nextDouble() - 0.5) * 0.001;
            _professionals[idx] = current.copyWith(
              location: LatLng(newLat, newLng),
            );
          }
        }
      });
    });
  }

  Future<void> _findWorker() async {
    final matchingProfessionals = _professionals
        .where((p) => _isCategoryMatch(p.category, widget.serviceTitle))
        .toList();

    if (matchingProfessionals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No ${widget.serviceTitle} workers available right now.',
          ),
        ),
      );
      return;
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final customerId = user?.uid ?? SessionManager.customerDocId ?? 'dummy_customer_id';
      
      String customerName = 'Customer';
      String? customerPhone;
      String? issueImageUrl;

      try {
        final customerDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .get();
        
        if (customerDoc.exists) {
          final customerData = customerDoc.data() ?? {};
          // Fetch customer info directly from customers collection
          customerName = customerData['fullName'] ?? customerData['name'] ?? 'Customer';
          customerPhone = customerData['phone'] ?? customerData['phoneNumber'];

          debugPrint('[FindProfessional] Customer data fetched - Name: $customerName, ID: $customerId');
        } else {
          debugPrint('[FindProfessional] Customer document not found for ID: $customerId');
        }
      } catch (e) {
        debugPrint('[FindProfessional] Error fetching customer: $e');
      }

      if (widget.issueImageFile != null) {
        try {
          issueImageUrl = await CloudinaryService.uploadCustomerImage(widget.issueImageFile!);
          debugPrint('[FindProfessional] Uploaded issue image to Cloudinary');
        } catch (e) {
          debugPrint('[FindProfessional] Cloudinary upload failed: $e');
          if (!mounted) return;
          Navigator.pop(context); // Remove loading overlay
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e')),
          );
          return;
        }
      }

      final jobRef = FirebaseFirestore.instance.collection('jobRequests').doc();
      
      final jobReq = JobRequest(
        id: jobRef.id,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        status: 'searching',
        jobType: widget.serviceTitle,
        description: (widget.issueDescription ?? '').trim().isEmpty
          ? null
          : widget.issueDescription!.trim(),
        issueImageUrl: issueImageUrl,
        customerLocation: _customerLatLng,
        createdAt: DateTime.now(),
        notifiedWorkerIds: matchingProfessionals.map((p) => p.id).toList(),
      );
      
      // Add to jobRequests with customer ref
      final jobData = jobReq.toMap();
      jobData['customerRef'] = FirebaseFirestore.instance.collection('customers').doc(customerId); // Reference to customer
      jobData['createdAt'] = FieldValue.serverTimestamp(); // Use server timestamp
      
      await jobRef.set(jobData);
      
      debugPrint('[FindProfessional] Job created - ID: ${jobRef.id}, Customer: $customerName ($customerId)');
      
      final batch = FirebaseFirestore.instance.batch();
      for (final p in matchingProfessionals) {
        final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notifRef, {
          'recipientId': p.id,
          'recipientRole': 'worker',
          'type': 'newJobRequest',
          'jobRequestId': jobRef.id,
          'title': 'New Job Request',
          'message': 'A new ${widget.serviceTitle} request is available nearby.',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      // Trigger backend FCM push to workers who were notified in Firestore.
      try {
        await http
            .post(
              Uri.parse('$_baseUrl/api/notifications/new-job-request'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'jobId': jobRef.id,
                'serviceTitle': widget.serviceTitle,
                'workerIds': matchingProfessionals.map((p) => p.id).toList(),
              }),
            )
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[FindProfessional] Push trigger failed: $e');
      }

      if (!mounted) return;
      Navigator.pop(context); // Remove loading overlay
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectingWorkerScreen(
            professionals: matchingProfessionals,
            serviceTitle: widget.serviceTitle,
            jobRequestId: jobRef.id,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Remove loading overlay
      debugPrint('[FindProfessional] Error creating request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating request: $e')),
      );
    }
  }

  Future<void> _scheduleWorker() async {
    if (_professionals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No professionals available right now.')),
      );
      return;
    }

    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2563EB),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !mounted) return;

    final formattedDate =
        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';

    // Show quick-select time options dialog
    final timeSelected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Preferred Time',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick select time options
              ..._timeOptions.map(
                (time) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, time),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(time, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  // Custom time picker if not in quick options
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2563EB),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (pickedTime != null && ctx.mounted) {
                    Navigator.pop(ctx, pickedTime.format(context));
                  }
                },
                child: const Text(
                  'Custom Time',
                  style: TextStyle(color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (timeSelected == null || !mounted) return;

    final formattedTime = timeSelected;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Schedule Worker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${widget.serviceTitle}',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(formattedDate, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(formattedTime, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final scheduledFor = _resolveScheduledFor(pickedDate, formattedTime);
      // Fetch customer info from Firestore
      final user = FirebaseAuth.instance.currentUser;
      final customerId = user?.uid ?? SessionManager.customerDocId ?? '';
      String customerName = 'Customer';
      String? customerPhone;
      String? issueImageUrl;

      if (customerId.isNotEmpty) {
        try {
          final customerDoc = await FirebaseFirestore.instance
              .collection('customers')
              .doc(customerId)
              .get();
          if (customerDoc.exists) {
            final d = customerDoc.data() ?? {};
            customerName = (d['fullName'] ?? d['name'] ?? 'Customer').toString();
            customerPhone =
                (d['phone'] ?? d['phoneNumber'])?.toString();
          }
        } catch (e) {
          debugPrint('[FindProfessional] Error fetching customer for schedule: $e');
        }
      }

      if (widget.issueImageFile != null) {
        try {
          issueImageUrl = await CloudinaryService.uploadCustomerImage(widget.issueImageFile!);
          debugPrint('[FindProfessional] Uploaded scheduled issue image to Cloudinary');
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e')),
          );
          return;
        }
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduledBookingScreen(
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            customerLat: _customerLatLng.latitude,
            customerLng: _customerLatLng.longitude,
            serviceTitle: widget.serviceTitle,
            category: _serviceToWorkerCategory(widget.serviceTitle),
            scheduledDate: formattedDate,
            scheduledTime: formattedTime,
            scheduledFor: scheduledFor,
            issueDescription: (widget.issueDescription ?? '').trim().isEmpty
                ? null
                : widget.issueDescription!.trim(),
            issueImageUrl: issueImageUrl,
            availableWorkers: _professionals,
          ),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Customer marker
    markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: _customerLatLng,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Worker markers
    for (final p in _professionals) {
      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: p.location,
          infoWindow: InfoWindow(
            title: p.name,
              snippet: '${p.timeToBook} away • ⭐ ${p.rating.toStringAsFixed(1)} (${p.reviewCount})',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    super.dispose();
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
        title: Text(
          widget.serviceTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomSheet()),
          // Loading indicator overlay
          if (_isLoadingWorkers)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _userLocation,
        zoom: 15,
      ),
      onMapCreated: (controller) => _mapController = controller,
      markers: _buildMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_professionals.length} workers available nearby. '
                        'The first worker to accept your request will be assigned.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _cashOnlySelected = !_cashOnlySelected;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _cashOnlySelected
                                ? const Color(0xFF2563EB)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _cashOnlySelected
                                  ? const Color(0xFF2563EB)
                                  : Colors.blue.shade200,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.payments,
                                  size: 18,
                                  color: _cashOnlySelected
                                      ? Colors.white
                                      : const Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cash Only',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _cashOnlySelected
                                        ? Colors.white
                                        : const Color(0xFF2563EB),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _language,
                      items: _languageOptions,
                      icon: Icons.language,
                      onChanged: (v) =>
                          setState(() => _language = v ?? 'Sinhala'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _findWorker,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text(
                          'Find a Worker Now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.black87,
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
                        onPressed: _scheduleWorker,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text(
                          'Schedule Worker',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
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
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(e, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
