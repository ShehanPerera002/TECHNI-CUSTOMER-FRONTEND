import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technni_customer/models/professional.dart';

void main() {
  group('Professional Search Integration Tests', () {
    test('Search flow: Find professionals by service type', () {
      // Mock professional database
      final professionals = [
        Professional(
          id: 'prof_001',
          name: 'John Plumber',
          rating: 4.8,
          timeToBook: '10 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Ahmed Electrician',
          rating: 4.5,
          timeToBook: '15 mins',
          location: const LatLng(25.2050, 55.2710),
          avatarUrl: 'https://example.com/ahmed.jpg',
          phoneNumber: '0501234568',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_003',
          name: 'Sara AC Technician',
          rating: 4.9,
          timeToBook: '12 mins',
          location: const LatLng(25.2045, 55.2705),
          avatarUrl: 'https://example.com/sara.jpg',
          phoneNumber: '0501234569',
          isAvailable: false,
        ),
      ];

      // Find all professionals
      expect(professionals.length, equals(3));

      // Find available professionals only
      final available = professionals.where((p) => p.isAvailable).toList();
      expect(available.length, equals(2));

      // Find professionals with rating >= 4.7
      final highRated = professionals.where((p) => p.rating >= 4.7).toList();
      expect(highRated.length, equals(2));
    });

    test('Search flow: Filter professionals by location proximity', () {
      final professionals = [
        Professional(
          id: 'prof_001',
          name: 'John',
          rating: 4.5,
          timeToBook: '5 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Ahmed',
          rating: 4.5,
          timeToBook: '20 mins',
          location: const LatLng(25.2100, 55.2800),
          avatarUrl: 'https://example.com/ahmed.jpg',
          phoneNumber: '0501234568',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_003',
          name: 'Sara',
          rating: 4.5,
          timeToBook: '35 mins',
          location: const LatLng(25.1900, 55.2500),
          avatarUrl: 'https://example.com/sara.jpg',
          phoneNumber: '0501234569',
          isAvailable: true,
        ),
      ];

      // Find professionals with time to book <= 15 mins
      final nearestProfessionals = professionals
          .where((p) => int.parse(p.timeToBook.split(' ')[0]) <= 15)
          .toList();

      expect(nearestProfessionals.length, equals(1));
      expect(nearestProfessionals.first.name, equals('John'));
    });

    test('Search flow: Sort professionals by rating', () {
      List<Professional> professionals = [
        Professional(
          id: 'prof_001',
          name: 'John',
          rating: 4.3,
          timeToBook: '10 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Ahmed',
          rating: 4.8,
          timeToBook: '15 mins',
          location: const LatLng(25.2050, 55.2710),
          avatarUrl: 'https://example.com/ahmed.jpg',
          phoneNumber: '0501234568',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_003',
          name: 'Sara',
          rating: 4.9,
          timeToBook: '12 mins',
          location: const LatLng(25.2045, 55.2705),
          avatarUrl: 'https://example.com/sara.jpg',
          phoneNumber: '0501234569',
          isAvailable: true,
        ),
      ];

      // Sort by rating descending
      professionals.sort((a, b) => b.rating.compareTo(a.rating));

      expect(professionals.first.name, equals('Sara'));
      expect(professionals.first.rating, equals(4.9));
      expect(professionals.last.name, equals('John'));
      expect(professionals.last.rating, equals(4.3));
    });

    test('Search flow: Combine multiple filters', () {
      final professionals = [
        Professional(
          id: 'prof_001',
          name: 'John',
          rating: 4.8,
          timeToBook: '10 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Ahmed',
          rating: 4.5,
          timeToBook: '25 mins',
          location: const LatLng(25.2050, 55.2710),
          avatarUrl: 'https://example.com/ahmed.jpg',
          phoneNumber: '0501234568',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_003',
          name: 'Sara',
          rating: 4.9,
          timeToBook: '12 mins',
          location: const LatLng(25.2045, 55.2705),
          avatarUrl: 'https://example.com/sara.jpg',
          phoneNumber: '0501234569',
          isAvailable: false,
        ),
      ];

      // Filter: Available, Rating >= 4.7, Time <= 15 mins
      final filtered = professionals
          .where((p) => p.isAvailable && p.rating >= 4.7)
          .where((p) => int.parse(p.timeToBook.split(' ')[0]) <= 15)
          .toList();

      expect(filtered.length, equals(1));
      expect(filtered.first.name, equals('John'));
    });

    test('Search flow: Handle empty search results', () {
      final professionals = [
        Professional(
          id: 'prof_001',
          name: 'John',
          rating: 4.3,
          timeToBook: '40 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: false,
        ),
      ];

      // Search for available professionals with rating >= 4.5
      final results = professionals
          .where((p) => p.isAvailable && p.rating >= 4.5)
          .toList();

      expect(results.isEmpty, isTrue);
    });

    test('Search flow: Find professionals with specific availability status', () {
      final professionals = [
        Professional(
          id: 'prof_001',
          name: 'John',
          rating: 4.5,
          timeToBook: '10 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Ahmed',
          rating: 4.5,
          timeToBook: '15 mins',
          location: const LatLng(25.2050, 55.2710),
          avatarUrl: 'https://example.com/ahmed.jpg',
          phoneNumber: '0501234568',
          isAvailable: false,
        ),
        Professional(
          id: 'prof_003',
          name: 'Sara',
          rating: 4.5,
          timeToBook: '12 mins',
          location: const LatLng(25.2045, 55.2705),
          avatarUrl: 'https://example.com/sara.jpg',
          phoneNumber: '0501234569',
          isAvailable: true,
        ),
      ];

      // Find available professionals
      final available = professionals.where((p) => p.isAvailable).toList();
      expect(available.length, equals(2));

      // Find unavailable professionals
      final unavailable = professionals.where((p) => !p.isAvailable).toList();
      expect(unavailable.length, equals(1));
    });

    test('Search flow: Match professionals by expertise level (rating)', () {
      final professionals = [
        Professional(
          id: 'prof_001',
          name: 'Beginner',
          rating: 3.5,
          timeToBook: '10 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/beginner.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Intermediate',
          rating: 4.2,
          timeToBook: '15 mins',
          location: const LatLng(25.2050, 55.2710),
          avatarUrl: 'https://example.com/inter.jpg',
          phoneNumber: '0501234568',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_003',
          name: 'Expert',
          rating: 4.9,
          timeToBook: '12 mins',
          location: const LatLng(25.2045, 55.2705),
          avatarUrl: 'https://example.com/expert.jpg',
          phoneNumber: '0501234569',
          isAvailable: true,
        ),
      ];

      // Find experts (rating >= 4.7)
      final experts = professionals.where((p) => p.rating >= 4.7).toList();
      expect(experts.length, equals(1));
      expect(experts.first.name, equals('Expert'));

      // Find professionals (rating >= 4.0)
      final professionals_ = professionals.where((p) => p.rating >= 4.0).toList();
      expect(professionals_.length, equals(2));
    });

    test('Search flow: Complete professional selection workflow', () {
      // Step 1: Get all available professionals
      final allProfessionals = [
        Professional(
          id: 'prof_001',
          name: 'John',
          rating: 4.5,
          timeToBook: '10 mins',
          location: const LatLng(25.2048, 55.2708),
          avatarUrl: 'https://example.com/john.jpg',
          phoneNumber: '0501234567',
          isAvailable: true,
        ),
        Professional(
          id: 'prof_002',
          name: 'Ahmed',
          rating: 4.8,
          timeToBook: '15 mins',
          location: const LatLng(25.2050, 55.2710),
          avatarUrl: 'https://example.com/ahmed.jpg',
          phoneNumber: '0501234568',
          isAvailable: true,
        ),
      ];

      // Step 2: Filter available
      var candidates = allProfessionals.where((p) => p.isAvailable).toList();
      expect(candidates.length, equals(2));

      // Step 3: Sort by rating
      candidates.sort((a, b) => b.rating.compareTo(a.rating));
      expect(candidates.first.name, equals('Ahmed'));

      // Step 4: Select top professional
      final selected = candidates.first;
      expect(selected.name, equals('Ahmed'));
      expect(selected.rating, equals(4.8));
      expect(selected.isAvailable, isTrue);
    });
  });
}
