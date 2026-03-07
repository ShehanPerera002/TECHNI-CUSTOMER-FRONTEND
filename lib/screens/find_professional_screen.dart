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
  late final List<Professional> _professionals;
  Professional? _selectedProfessional;
  String _paymentMethod = 'Cash';
  String _language = 'Sinhala';

  static const _paymentOptions = ['Cash', 'Card payment'];
  static const _languageOptions = ['Sinhala', 'English', 'Tamil'];

  @override
  void initState() {
    super.initState();
    _professionals = Professional.getDummyForCategory(widget.serviceTitle);
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _userLocation,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
            ..._professionals.map((p) => Marker(
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
                            child: const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
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
                              child: const Icon(Icons.person, size: 20, color: Colors.grey),
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
                height: 44,
                child: FilledButton.icon(
                  onPressed: _selectedProfessional != null
                      ? () {
                          // TODO: Navigate to profile
                        }
                      : null,
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text('Check Profile'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    foregroundColor: Colors.black87,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
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
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: Connect now
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Connect Now'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Schedule
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Schedule'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black87),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text(e, style: const TextStyle(fontSize: 14)),
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
