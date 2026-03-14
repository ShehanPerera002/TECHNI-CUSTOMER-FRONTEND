import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/professional.dart';
import 'connecting_worker_screen.dart';
import 'scheduled_booking_screen.dart';

/// Screen showing map with available professionals and booking options.
class FindProfessionalScreen extends StatefulWidget {
  final String serviceTitle;

  const FindProfessionalScreen({super.key, required this.serviceTitle});

  @override
  State<FindProfessionalScreen> createState() => _FindProfessionalScreenState();
}

class _FindProfessionalScreenState extends State<FindProfessionalScreen> {
  static const _userLocation = LatLng(6.9271, 79.8612);
  late List<Professional> _professionals;
  String _paymentMethod = 'Cash';
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

  @override
  void initState() {
    super.initState();
    _professionals = List.from(
      Professional.getDummyForCategory(widget.serviceTitle),
    );
    _startLiveMovement();
  }

  void _findWorker() {
    if (_professionals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No professionals available right now.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectingWorkerScreen(
          professionals: _professionals,
          serviceTitle: widget.serviceTitle,
        ),
      ),
    );
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

    if (pickedTime == null || !mounted) return;

    final formattedDate =
        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
    final formattedTime = pickedTime.format(context);

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduledBookingScreen(
            serviceTitle: widget.serviceTitle,
            scheduledDate: formattedDate,
            scheduledTime: formattedTime,
            availableWorkers: _professionals,
          ),
        ),
      );
    }
  }

  void _startLiveMovement() {
    _movementTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        for (final i in _movingIndices) {
          if (i >= _professionals.length) continue;
          final p = _professionals[i];
          final delta = 0.0008 * (_random.nextDouble() - 0.5) * 2;
          final newLat = p.location.latitude + delta;
          final newLng =
              p.location.longitude + delta * (_random.nextBool() ? 1 : -1);
          final newTime = _timeOptions[_random.nextInt(_timeOptions.length)];
          _professionals[i] = p.copyWith(
            location: LatLng(newLat, newLng),
            timeToBook: newTime,
          );
        }
      });
    });
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
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _userLocation,
        initialZoom: 15,
        minZoom: 13,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: _professionals
              .map(
                (p) => Marker(
                  point: p.location,
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        p.avatarUrl,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
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
