import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/professional.dart';
import 'emergency_help_screen.dart';

class WorkerOnTheWayScreen extends StatelessWidget {
  final Professional professional;
  final String serviceTitle;

  const WorkerOnTheWayScreen({
    super.key,
    required this.professional,
    required this.serviceTitle,
  });

  static const _customerLocation = LatLng(6.9271, 79.8612);

  @override
  Widget build(BuildContext context) {
    final routePoints = [_customerLocation, professional.location];

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
          serviceTitle,
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
          FlutterMap(
            options: const MapOptions(
              initialCenter: _customerLocation,
              initialZoom: 14.8,
              minZoom: 13,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: const Color(0xFF1E293B),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: professional.location,
                    width: 54,
                    height: 54,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(professional.avatarUrl),
                      ),
                    ),
                  ),
                  const Marker(
                    point: _customerLocation,
                    width: 46,
                    height: 46,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.my_location, color: Color(0xFF3B82F6)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 18,
            bottom: 355,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2A2A).withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'emergencyFab',
                backgroundColor: const Color(0xFFFF2A2A),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EmergencyHelpScreen(serviceTitle: serviceTitle),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _TripSheet(professional: professional),
          ),
        ],
      ),
    );
  }
}

class _TripSheet extends StatefulWidget {
  final Professional professional;

  const _TripSheet({required this.professional});

  @override
  State<_TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends State<_TripSheet> {
  static const _paymentOptions = ['Cash', 'Card payment'];
  static const _languageOptions = ['Sinhala', 'English', 'Tamil'];

  String _paymentMethod = _paymentOptions.first;
  String _language = _languageOptions.first;

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: const [
                Text(
                  'Worker is on the way',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '5 min...',
                  style: TextStyle(
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
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F1F1),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.call),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE1E1E1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      _PriceRow(label: 'Total price', value: 'Rs 1500'),
                      SizedBox(height: 8),
                      _PriceRow(label: 'Hourly Rate', value: 'Rs 200 / hr'),
                      SizedBox(height: 8),
                      _PriceRow(label: 'Materials', value: 'At Cost'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SelectionDropdown(
                        icon: Icons.payments,
                        value: _paymentMethod,
                        items: _paymentOptions,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _paymentMethod = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectionDropdown(
                        icon: Icons.language,
                        value: _language,
                        items: _languageOptions,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _language = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
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
