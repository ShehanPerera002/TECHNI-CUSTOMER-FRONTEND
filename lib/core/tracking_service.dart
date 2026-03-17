import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class TrackingService {
  static const _apiKey = 'YOUR_API_KEY_HERE';

  /// Stream worker's live location from Firestore
  static Stream<LatLng> workerLocationStream(String workerId) {
    return FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .snapshots()
        .where((doc) => doc.exists && doc['lat'] != null)
        .map(
          (doc) => LatLng(
            (doc['lat'] as num).toDouble(),
            (doc['lng'] as num).toDouble(),
          ),
        );
  }

  /// Fetch route polyline points from Directions API
  static Future<List<LatLng>> getRoutePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data['routes'].isEmpty) return [];

    final points = data['routes'][0]['overview_polyline']['points'] as String;
    return _decodePolyline(points);
  }

  /// Fetch ETA and distance from Distance Matrix API
  static Future<Map<String, String>> getETA(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=${origin.latitude},${origin.longitude}'
      '&destinations=${destination.latitude},${destination.longitude}'
      '&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return {'eta': '--', 'distance': '--'};

    final data = jsonDecode(response.body);
    final element = data['rows'][0]['elements'][0];

    return {
      'eta': element['duration']['text'] as String,
      'distance': element['distance']['text'] as String,
    };
  }

  /// Decode Google's encoded polyline format
  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
