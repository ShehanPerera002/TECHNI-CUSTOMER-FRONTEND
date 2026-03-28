import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:technni_customer/models/live_location.dart';

void main() {
  group('LiveLocation Model Tests', () {
    test('LiveLocation should create with required properties', () {
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 0.0,
        updatedAt: DateTime(2024, 3, 26, 10, 30),
      );

      expect(liveLocation.jobRequestId, equals('job_001'));
      expect(liveLocation.workerId, equals('worker_001'));
      expect(liveLocation.latitude, equals(25.2048));
      expect(liveLocation.longitude, equals(55.2708));
      expect(liveLocation.heading, equals(0.0));
    });

    test('LiveLocation should handle optional speed', () {
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 45.0,
        speed: 60.5,
        updatedAt: DateTime(2024, 3, 26, 10, 30),
      );

      expect(liveLocation.speed, equals(60.5));
    });

    test('LiveLocation should handle null speed', () {
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 0.0,
        updatedAt: DateTime(2024, 3, 26, 10, 30),
      );

      expect(liveLocation.speed, isNull);
    });

    test('LiveLocation coordinates should be valid', () {
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 90.0,
        updatedAt: DateTime(2024, 3, 26, 10, 30),
      );

      expect(liveLocation.latitude >= -90 && liveLocation.latitude <= 90, isTrue);
      expect(liveLocation.longitude >= -180 && liveLocation.longitude <= 180, isTrue);
    });

    test('LiveLocation heading should be between 0 and 360', () {
      final headings = [0.0, 90.0, 180.0, 270.0, 360.0];

      for (var heading in headings) {
        final liveLocation = LiveLocation(
          jobRequestId: 'job_001',
          workerId: 'worker_001',
          latitude: 25.2048,
          longitude: 55.2708,
          heading: heading,
          updatedAt: DateTime(2024, 3, 26, 10, 30),
        );

        expect(
          liveLocation.heading >= 0 && liveLocation.heading <= 360,
          isTrue,
        );
      }
    });

    test('LiveLocation toMap should return valid map', () {
      final now = DateTime(2024, 3, 26, 10, 30);
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 45.0,
        speed: 60.5,
        updatedAt: now,
      );

      final map = liveLocation.toMap();

      expect(map['workerId'], equals('worker_001'));
      expect(map['latitude'], equals(25.2048));
      expect(map['longitude'], equals(55.2708));
      expect(map['heading'], equals(45.0));
      expect(map['speed'], equals(60.5));
      expect(map['updatedAt'], isA<Timestamp>());
    });

    test('LiveLocation should handle different coordinates', () {
      final locations = [
        (25.2048, 55.2708), // Dubai
        (24.4539, 54.3773), // Abu Dhabi
        (25.3548, 55.3643), // Another Dubai location
      ];

      for (var (lat, lng) in locations) {
        final liveLocation = LiveLocation(
          jobRequestId: 'job_001',
          workerId: 'worker_001',
          latitude: lat,
          longitude: lng,
          heading: 0.0,
          updatedAt: DateTime(2024, 3, 26, 10, 30),
        );

        expect(liveLocation.latitude, equals(lat));
        expect(liveLocation.longitude, equals(lng));
      }
    });

    test('LiveLocation updatedAt should be valid timestamp', () {
      final updateTime = DateTime(2024, 3, 26, 10, 30, 45);
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 0.0,
        updatedAt: updateTime,
      );

      expect(liveLocation.updatedAt, equals(updateTime));
      expect(liveLocation.updatedAt.isBefore(DateTime.now()), isTrue);
    });

    test('LiveLocation should support different worker and job IDs', () {
      final ids = [
        ('job_001', 'worker_001'),
        ('job_002', 'worker_002'),
        ('job_abc', 'worker_xyz'),
      ];

      for (var (jobId, workerId) in ids) {
        final liveLocation = LiveLocation(
          jobRequestId: jobId,
          workerId: workerId,
          latitude: 25.2048,
          longitude: 55.2708,
          heading: 0.0,
          updatedAt: DateTime(2024, 3, 26, 10, 30),
        );

        expect(liveLocation.jobRequestId, equals(jobId));
        expect(liveLocation.workerId, equals(workerId));
      }
    });

    test('LiveLocation speed should be non-negative when provided', () {
      final liveLocation = LiveLocation(
        jobRequestId: 'job_001',
        workerId: 'worker_001',
        latitude: 25.2048,
        longitude: 55.2708,
        heading: 0.0,
        speed: 50.0,
        updatedAt: DateTime(2024, 3, 26, 10, 30),
      );

      expect(liveLocation.speed! >= 0, isTrue);
    });
  });
}
