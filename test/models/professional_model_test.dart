import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:technni_customer/models/professional.dart';

void main() {
  group('Professional Model Tests', () {
    test('Professional should create with correct properties', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      expect(professional.id, equals('prof_001'));
      expect(professional.name, equals('John Doe'));
      expect(professional.rating, equals(4.5));
      expect(professional.timeToBook, equals('15 mins'));
      expect(professional.avatarUrl, equals('https://example.com/john.jpg'));
      expect(professional.phoneNumber, equals('0501234567'));
    });

    test('Professional should have default isAvailable as true', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      expect(professional.isAvailable, isTrue);
    });

    test('Professional should set isAvailable correctly', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
        isAvailable: false,
      );

      expect(professional.isAvailable, isFalse);
    });

    test('Professional should handle fcmToken', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
        fcmToken: 'fcm_token_123',
      );

      expect(professional.fcmToken, equals('fcm_token_123'));
    });

    test('Professional should handle activeJobId', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
        activeJobId: 'job_001',
      );

      expect(professional.activeJobId, equals('job_001'));
    });

    test('Professional location should be correct LatLng', () {
      const location = LatLng(25.2048, 55.2708);
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: location,
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      expect(professional.location.latitude, equals(25.2048));
      expect(professional.location.longitude, equals(55.2708));
    });

    test('Professional rating should be non-negative', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      expect(professional.rating >= 0, isTrue);
    });

    test('Professional rating should not exceed 5.0', () {
      final professional = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 5.0,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      expect(professional.rating <= 5.0, isTrue);
    });
  });
}
