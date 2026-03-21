import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/booking_service.dart';
import '../core/tracking_service.dart';
import '../models/professional.dart';
import 'emergency_help_screen.dart';
import 'in_app_call_screen.dart';
import 'in_app_chat_screen.dart';
import 'job_tracking_screen.dart';

class WorkerOnTheWayScreen extends StatefulWidget {
  final Professional professional;
  final String serviceTitle;
  final String? jobRequestId;

  const WorkerOnTheWayScreen({
    super.key,
    required this.professional,
    required this.serviceTitle,
    this.jobRequestId,
  });

  @override
  State<WorkerOnTheWayScreen> createState() => _WorkerOnTheWayScreenState();
}

class _WorkerOnTheWayScreenState extends State<WorkerOnTheWayScreen> {
  GoogleMapController? _mapController;

  LatLng? _customerLatLng;
  LatLng? _workerLatLng;
  List<LatLng> _routePoints = [];
  String _eta = '--';
  String _distance = '--';
  LatLng? _lastRouteUpdatePosition;
  DateTime? _lastRouteUpdateTime;

  StreamSubscription<DocumentSnapshot>? _workerLocationSub;
  StreamSubscription<DocumentSnapshot>? _workerFallbackSub;
  StreamSubscription<DocumentSnapshot>? _jobStatusSub;
  StreamSubscription<Position>? _customerLocationSub;

  @override
  void initState() {
    super.initState();
    _initCustomerLocation();
    _listenToWorkerLocation();
    _listenToJobStatus();
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
    if (widget.jobRequestId == null) return;

    _workerLocationSub = FirebaseFirestore.instance
        .collection('liveLocations')
        .doc(widget.jobRequestId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      final lat = doc.data()?['latitude'];
      final lng = doc.data()?['longitude'];
      if (lat != null && lng != null && mounted) {
        setState(() {
          _workerLatLng = LatLng(lat as double, lng as double);
        });
        if (_workerLatLng != null) {
          _mapController?.animateCamera(CameraUpdate.newLatLng(_workerLatLng!));
          _updateRouteAndETA();
        }
      }
    });

    // 2. Fallback Source: workers (general updates)
    _workerFallbackSub = FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.professional.id)
        .snapshots()
        .listen((doc) {
      // Only use fallback if primary source hasn't provided data yet
      if (!doc.exists || _workerLatLng != null) return;
      final lat = doc.data()?['lat'];
      final lng = doc.data()?['lng'];
      if (lat != null && lng != null && mounted) {
        debugPrint('WorkerOnTheWayScreen: Using fallback location from workers collection');
        setState(() {
          _workerLatLng = LatLng(lat as double, lng as double);
        });
        if (_workerLatLng != null) {
          _mapController?.animateCamera(CameraUpdate.newLatLng(_workerLatLng!));
          _updateRouteAndETA();
        }
      }
    });
  }

  /// Listen for job status changes to auto-navigate
  void _listenToJobStatus() {
    _jobStatusSub = FirebaseFirestore.instance
        .collection('jobRequests')
        .doc(widget.jobRequestId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      final status = doc.data()?['status'];
      
      debugPrint('WorkerOnTheWayScreen: Job status is $status');

      if ((status == 'arrived' || status == 'workStarted' || status == 'completed') && mounted) {
        debugPrint('WorkerOnTheWayScreen: Navigating to JobTrackingScreen');
        _jobStatusSub?.cancel();
        _customerLocationTimer?.cancel();
        
        // Show notification if it's the first time arriving
        if (status == 'arrived') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The worker has arrived!'),
              backgroundColor: Color(0xFF2563EB),
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Navigate to Job Tracking Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => JobTrackingScreen(
              workerName: widget.professional.name,
              serviceTitle: widget.serviceTitle,
              jobRequestId: widget.jobRequestId,
            ),
          ),
        );
      }
    });

    // Start updating customer location in Firestore periodically
    _startCustomerLocationUpdates();
  }

  Timer? _customerLocationTimer;
  void _startCustomerLocationUpdates() {
    _customerLocationTimer?.cancel();
    _customerLocationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted || widget.jobRequestId == null) {
        timer.cancel();
        return;
      }

      try {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          await FirebaseFirestore.instance
              .collection('jobRequests')
              .doc(widget.jobRequestId)
              .update({
            'customerLocation': GeoPoint(pos.latitude, pos.longitude),
          });
          debugPrint('WorkerOnTheWayScreen: Updated customer location in Firestore');
        }
      } catch (e) {
        debugPrint('WorkerOnTheWayScreen: Error updating location: $e');
      }
    });
  }

  /// Fetch route polyline + ETA whenever locations update
  Future<void> _updateRouteAndETA() async {
    if (_customerLatLng == null || _workerLatLng == null) return;

    // Optimization: Only update route if the worker has moved significantly (>50m) 
    // or if it has been more than 20 seconds since last update.
    final now = DateTime.now();
    if (_lastRouteUpdatePosition != null && _lastRouteUpdateTime != null) {
      final distanceMoved = Geolocator.distanceBetween(
        _lastRouteUpdatePosition!.latitude,
        _lastRouteUpdatePosition!.longitude,
        _workerLatLng!.latitude,
        _workerLatLng!.longitude,
      );
      final timeDiff = now.difference(_lastRouteUpdateTime!);

      if (distanceMoved < 50 && timeDiff < const Duration(seconds: 20)) {
        return; // Skip update
      }
    }

    try {
      final results = await Future.wait([
        TrackingService.getRoutePoints(_workerLatLng!, _customerLatLng!),
        TrackingService.getETA(_workerLatLng!, _customerLatLng!),
      ]);

      if (!mounted) return;
      setState(() {
        _lastRouteUpdatePosition = _workerLatLng;
        _lastRouteUpdateTime = now;
        _routePoints = results[0] as List<LatLng>;
        final etaData = results[1] as Map<String, String>;
        _eta = etaData['eta'] ?? '--';
        _distance = etaData['distance'] ?? '--';
      });
    } catch (e) {
      debugPrint('Error updating route/ETA: $e');
    }
  }

  @override
  void dispose() {
    _workerLocationSub?.cancel();
    _workerFallbackSub?.cancel();
    _jobStatusSub?.cancel();
    _customerLocationSub?.cancel();
    _customerLocationTimer?.cancel();
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
              if (_workerLatLng != null)
                Marker(
                  markerId: const MarkerId('worker'),
                  position: _workerLatLng!,
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
              jobRequestId: widget.jobRequestId,
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
  final String? jobRequestId;

  const _TripSheet({
    required this.professional,
    required this.serviceTitle,
    required this.eta,
    this.jobRequestId,
  });

  @override
  State<_TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends State<_TripSheet> {
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
                
                // Dynamic Status Button
                if (widget.jobRequestId != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('jobRequests')
                        .doc(widget.jobRequestId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String label = 'Waiting for Worker to Arrive';
                      Color btnColor = Colors.grey.shade400;
                      IconData icon = Icons.sync;

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final status = snapshot.data!.get('status');
                        if (status == 'arrived') {
                          label = 'Worker has Arrived';
                          btnColor = const Color(0xFF2563EB);
                          icon = Icons.check_circle;
                        } else if (status == 'workStarted') {
                          label = 'Work in Progress';
                          btnColor = Colors.green;
                          icon = Icons.play_circle_outline;
                        }
                      }

                      return SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: Icon(icon, size: 18),
                          label: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: btnColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text(
                        'Waiting for Worker to Arrive',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
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
