import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/booking_service.dart';
import '../core/tracking_service.dart';
import '../models/professional.dart';
import 'emergency_help_screen.dart';
import 'in_app_call_screen.dart';
import 'in_app_chat_screen.dart';

class WorkerOnTheWayScreen extends StatefulWidget {
  final Professional professional;
  final String serviceTitle;

  const WorkerOnTheWayScreen({
    super.key,
    required this.professional,
    required this.serviceTitle,
  });

  @override
  State<WorkerOnTheWayScreen> createState() => _WorkerOnTheWayScreenState();
}

class _WorkerOnTheWayScreenState extends State<WorkerOnTheWayScreen> {
  GoogleMapController? _mapController;

  LatLng? _customerLatLng;
  LatLng _workerLatLng = const LatLng(6.9271, 79.8612);
  List<LatLng> _routePoints = [];
  String _eta = '--';
  String _distance = '--';

  StreamSubscription<LatLng>? _workerLocationSub;
  StreamSubscription<Position>? _customerLocationSub;

  @override
  void initState() {
    super.initState();
    _initCustomerLocation();
    _listenToWorkerLocation();
  }

  /// Get customer's real GPS location
  Future<void> _initCustomerLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _customerLatLng = LatLng(pos.latitude, pos.longitude);
    });

    // Once we have customer location, fetch route
    _updateRouteAndETA();

    // Keep updating customer location too
    _customerLocationSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
          ),
        ).listen((pos) {
          setState(() {
            _customerLatLng = LatLng(pos.latitude, pos.longitude);
          });
          _updateRouteAndETA();
        });
  }

  /// Listen to worker's live location from Firestore
  void _listenToWorkerLocation() {
    _workerLocationSub =
        TrackingService.workerLocationStream(widget.professional.id).listen((
          latLng,
        ) {
          setState(() => _workerLatLng = latLng);

          // Smoothly move camera to keep worker in view
          _mapController?.animateCamera(CameraUpdate.newLatLng(_workerLatLng));

          _updateRouteAndETA();
        });
  }

  /// Fetch route polyline + ETA whenever locations update
  Future<void> _updateRouteAndETA() async {
    if (_customerLatLng == null) return;

    final results = await Future.wait([
      TrackingService.getRoutePoints(_workerLatLng, _customerLatLng!),
      TrackingService.getETA(_workerLatLng, _customerLatLng!),
    ]);

    if (!mounted) return;
    setState(() {
      _routePoints = results[0] as List<LatLng>;
      final etaData = results[1] as Map<String, String>;
      _eta = etaData['eta'] ?? '--';
      _distance = etaData['distance'] ?? '--';
    });
  }

  @override
  void dispose() {
    _workerLocationSub?.cancel();
    _customerLocationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerPos = _customerLatLng ?? const LatLng(6.9271, 79.8612);

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
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: customerPos,
              zoom: 14.8,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              // Worker marker
              Marker(
                markerId: const MarkerId('worker'),
                position: _workerLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: InfoWindow(title: widget.professional.name),
              ),
              // Customer marker
              Marker(
                markerId: const MarkerId('customer'),
                position: customerPos,
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            },
            // Route polyline
            polylines: _routePoints.isNotEmpty
                ? {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: _routePoints,
                      color: const Color(0xFF2563EB),
                      width: 5,
                    ),
                  }
                : {},
          ),

          // ETA chip at top
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ETA: $_eta  •  $_distance',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Emergency button
          Positioned(
            right: 18,
            bottom: 355,
            child: FloatingActionButton(
              heroTag: 'emergencyFab',
              backgroundColor: const Color(0xFFFF2A2A),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EmergencyHelpScreen(serviceTitle: widget.serviceTitle),
                ),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
            ),
          ),

          // Bottom trip sheet
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _TripSheet(
              professional: widget.professional,
              serviceTitle: widget.serviceTitle,
              eta: _eta,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripSheet extends StatefulWidget {
  final Professional professional;
  final String serviceTitle;
  final String eta;

  const _TripSheet({
    required this.professional,
    required this.serviceTitle,
    required this.eta,
  });

  @override
  State<_TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends State<_TripSheet> {
  static const _languageOptions = ['Sinhala', 'English', 'Tamil'];
  String _language = _languageOptions.first;

  void _confirmWork() {
    BookingService.instance.completeBooking(
      BookingService.instance.bookings
          .firstWhere(
            (b) =>
                b.serviceTitle == widget.serviceTitle &&
                b.workerName == widget.professional.name,
            orElse: () => BookingService.instance.bookings.first,
          )
          .id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.professional.name} has completed the work!'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const Text(
                  'Worker is on the way',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.eta,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Worker info row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        widget.professional.avatarUrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.professional.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'PIN number - 12345',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F1F1),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InAppChatScreen(
                            professional: widget.professional,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F1F1),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InAppCallScreen(
                            professional: widget.professional,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.call),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Cash only badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments, size: 18, color: Color(0xFF22C55E)),
                      SizedBox(width: 8),
                      Text(
                        'Cash Only',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22C55E),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Language dropdown
                _SelectionDropdown(
                  icon: Icons.language,
                  value: _language,
                  items: _languageOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _language = value);
                  },
                ),
                const SizedBox(height: 12),
                // Confirm button
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirmWork,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

class _SelectionDropdown extends StatelessWidget {
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SelectionDropdown({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        item,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
