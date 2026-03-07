import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/professional.dart';

/// Screen showing map with available professionals and booking options.
class FindProfessionalScreen extends StatefulWidget {
  final String serviceTitle;

  const FindProfessionalScreen({
    super.key,
    required this.serviceTitle,
  });

  @override
  State<FindProfessionalScreen> createState() => _FindProfessionalScreenState();
}

class _FindProfessionalScreenState extends State<FindProfessionalScreen> {
  static const _userLocation = LatLng(6.9271, 79.8612);
  late List<Professional> _professionals;
  Professional? _selectedProfessional;
  String _paymentMethod = 'Cash';
  String _language = 'Sinhala';
  Timer? _movementTimer;
  final Random _random = Random();
  static const _movingIndices = [0, 2]; // Saman & Kamala get live movement
  static const _timeOptions = ['10 min', '12 min', '15 min', '18 min', '20 min'];

  static const _paymentOptions = ['Cash', 'Card payment'];
  static const _languageOptions = ['Sinhala', 'English', 'Tamil'];

  @override
  void initState() {
    super.initState();
    _professionals = List.from(Professional.getDummyForCategory(widget.serviceTitle));
    _startLiveMovement();
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
          final newLng = p.location.longitude + delta * (_random.nextBool() ? 1 : -1);
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(),
          ),
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
          urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: _professionals.map((p) => Marker(
                  point: p.location,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedProfessional = p),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedProfessional?.id == p.id
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          width: 2,
                        ),
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList(),
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
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _professionals.length,
                  itemBuilder: (context, index) {
                    final p = _professionals[index];
                    final isSelected = _selectedProfessional?.id == p.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedProfessional = p),
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.only(
                          right: index < _professionals.length - 1 ? 12 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.grey.shade200
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.timeToBook,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(p.avatarUrl),
                              onBackgroundImageError: (object, stackTrace) {},
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    size: 10, color: Colors.amber.shade700),
                                const SizedBox(width: 2),
                                Text(
                                  '${p.rating}/5',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedProfessional != null
                      ? () {
                          // TODO: Navigate to profile
                        }
                      : null,
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text(
                    'Check Profile',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedProfessional != null ? const Color(0xFFFBBF24) : Colors.grey.shade300,
                    foregroundColor: _selectedProfessional != null ? Colors.black87 : Colors.grey.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _paymentMethod,
                      items: _paymentOptions,
                      icon: Icons.payments,
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v ?? 'Cash'),
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
                        onPressed: () {
                          // TODO: Connect now
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text(
                          'Connect Now',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Schedule
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text(
                          'Schedule',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade800,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 6),
                        Text(e, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
