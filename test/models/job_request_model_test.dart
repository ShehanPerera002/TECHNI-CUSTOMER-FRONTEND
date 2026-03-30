import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technni_customer/models/job_request.dart';

void main() {
  group('JobRequest Model Tests', () {
    test('JobRequest should create with required properties', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        status: 'searching',
        jobType: 'Plumbing',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: DateTime(2024, 3, 26),
      );

      expect(jobRequest.id, equals('job_001'));
      expect(jobRequest.customerId, equals('cust_001'));
      expect(jobRequest.customerName, equals('John'));
      expect(jobRequest.status, equals('searching'));
      expect(jobRequest.jobType, equals('Plumbing'));
    });

    test('JobRequest should handle optional properties', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        customerPhone: '0501234567',
        status: 'searching',
        jobType: 'Plumbing',
        description: 'Fix the leaky pipe',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: DateTime(2024, 3, 26),
        fare: 150.0,
        duration: 45,
      );

      expect(jobRequest.customerPhone, equals('0501234567'));
      expect(jobRequest.description, equals('Fix the leaky pipe'));
      expect(jobRequest.fare, equals(150.0));
      expect(jobRequest.duration, equals(45));
    });

    test('JobRequest should handle different statuses', () {
      const statuses = [
        'searching',
        'accepted',
        'confirmed',
        'started',
        'completed',
        'cancelled'
      ];

      for (var status in statuses) {
        final jobRequest = JobRequest(
          id: 'job_001',
          customerId: 'cust_001',
          customerName: 'John',
          status: status,
          jobType: 'Plumbing',
          customerLocation: const LatLng(25.2048, 55.2708),
          createdAt: DateTime(2024, 3, 26),
        );

        expect(jobRequest.status, equals(status));
      }
    });

    test('JobRequest should handle notified and rejected worker IDs', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        status: 'searching',
        jobType: 'Plumbing',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: DateTime(2024, 3, 26),
        notifiedWorkerIds: ['worker_001', 'worker_002'],
        rejectedWorkerIds: ['worker_003'],
      );

      expect(jobRequest.notifiedWorkerIds.length, equals(2));
      expect(jobRequest.rejectedWorkerIds.length, equals(1));
      expect(jobRequest.notifiedWorkerIds, contains('worker_001'));
      expect(jobRequest.rejectedWorkerIds, contains('worker_003'));
    });

    test('JobRequest should handle worker location', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        status: 'searching',
        jobType: 'Plumbing',
        customerLocation: const LatLng(25.2048, 55.2708),
        workerLocation: const LatLng(25.2050, 55.2710),
        createdAt: DateTime(2024, 3, 26),
      );

      expect(jobRequest.workerLocation, isNotNull);
      expect(jobRequest.workerLocation!.latitude, equals(25.2050));
      expect(jobRequest.workerLocation!.longitude, equals(55.2710));
    });

    test('JobRequest should handle all timestamps', () {
      final now = DateTime(2024, 3, 26, 10, 30);
      final accepted = DateTime(2024, 3, 26, 10, 35);
      final confirmed = DateTime(2024, 3, 26, 10, 40);
      final started = DateTime(2024, 3, 26, 11, 0);
      final completed = DateTime(2024, 3, 26, 11, 45);

      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        status: 'completed',
        jobType: 'Plumbing',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: now,
        workerAcceptedAt: accepted,
        customerConfirmedAt: confirmed,
        jobStartedAt: started,
        completedAt: completed,
      );

      expect(jobRequest.createdAt, equals(now));
      expect(jobRequest.workerAcceptedAt, equals(accepted));
      expect(jobRequest.customerConfirmedAt, equals(confirmed));
      expect(jobRequest.jobStartedAt, equals(started));
      expect(jobRequest.completedAt, equals(completed));
    });

    test('JobRequest should handle cancellation', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        status: 'cancelled',
        jobType: 'Plumbing',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: DateTime(2024, 3, 26),
        cancelledAt: DateTime(2024, 3, 26, 10, 45),
        cancelReason: 'Customer cancelled',
      );

      expect(jobRequest.status, equals('cancelled'));
      expect(jobRequest.cancelledAt, isNotNull);
      expect(jobRequest.cancelReason, equals('Customer cancelled'));
    });

    test('JobRequest should have empty notification lists by default', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        status: 'searching',
        jobType: 'Plumbing',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: DateTime(2024, 3, 26),
      );

      expect(jobRequest.notifiedWorkerIds, isEmpty);
      expect(jobRequest.rejectedWorkerIds, isEmpty);
    });

    test('JobRequest toMap should return valid map', () {
      final jobRequest = JobRequest(
        id: 'job_001',
        customerId: 'cust_001',
        customerName: 'John',
        customerPhone: '0501234567',
        status: 'searching',
        jobType: 'Plumbing',
        description: 'Fix pipe',
        customerLocation: const LatLng(25.2048, 55.2708),
        createdAt: DateTime(2024, 3, 26),
        fare: 150.0,
        duration: 45,
      );

      final map = jobRequest.toMap();

      expect(map['customerId'], equals('cust_001'));
      expect(map['customerName'], equals('John'));
      expect(map['customerPhone'], equals('0501234567'));
      expect(map['jobType'], equals('Plumbing'));
      expect(map['fare'], equals(150.0));
    });
  });
}
