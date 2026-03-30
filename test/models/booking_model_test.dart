import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/models/booking.dart';
import 'package:technni_customer/models/professional.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('Booking Model Tests', () {
    test('Booking should create with required properties', () {
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26),
      );

      expect(booking.id, equals('booking_001'));
      expect(booking.serviceTitle, equals('Plumbing'));
      expect(booking.type, equals(BookingType.realTime));
      expect(booking.status, equals(BookingStatus.pending));
    });

    test('Booking should support scheduled type', () {
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.scheduled,
        status: BookingStatus.confirmed,
        createdAt: DateTime(2024, 3, 26),
        scheduledDate: '2024-03-27',
        scheduledTime: '10:00 AM',
      );

      expect(booking.type, equals(BookingType.scheduled));
      expect(booking.scheduledDate, equals('2024-03-27'));
      expect(booking.scheduledTime, equals('10:00 AM'));
    });

    test('Booking should support all status types', () {
      final statuses = [
        BookingStatus.pending,
        BookingStatus.confirmed,
        BookingStatus.inProgress,
        BookingStatus.completed,
        BookingStatus.cancelled,
      ];

      for (var status in statuses) {
        final booking = Booking(
          id: 'booking_001',
          serviceTitle: 'Plumbing',
          type: BookingType.realTime,
          status: status,
          createdAt: DateTime(2024, 3, 26),
        );

        expect(booking.status, equals(status));
      }
    });

    test('Booking should handle worker information', () {
      final worker = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.confirmed,
        createdAt: DateTime(2024, 3, 26),
        worker: worker,
      );

      expect(booking.worker, equals(worker));
      expect(booking.workerName, equals('John Doe'));
      expect(booking.workerRating, equals(4.5));
    });

    test('Booking copyWith should update status', () {
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26),
      );

      final updatedBooking = booking.copyWith(status: BookingStatus.confirmed);

      expect(updatedBooking.status, equals(BookingStatus.confirmed));
      expect(updatedBooking.id, equals(booking.id));
    });

    test('Booking copyWith should update worker', () {
      final worker = Professional(
        id: 'prof_001',
        name: 'John Doe',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26),
      );

      final updatedBooking = booking.copyWith(worker: worker);

      expect(updatedBooking.worker, equals(worker));
      expect(updatedBooking.workerName, equals('John Doe'));
    });

    test('Booking should maintain immutability', () {
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26),
      );

      final updatedBooking = booking.copyWith(status: BookingStatus.confirmed);

      expect(booking.status, equals(BookingStatus.pending));
      expect(updatedBooking.status, equals(BookingStatus.confirmed));
    });

    test('Booking should handle null worker properties', () {
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26),
      );

      expect(booking.worker, isNull);
      expect(booking.workerName, isNull);
      expect(booking.workerAvatarUrl, isNull);
      expect(booking.workerRating, isNull);
    });

    test('Booking createdAt timestamp should be valid', () {
      final createdTime = DateTime(2024, 3, 26, 10, 30);
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: createdTime,
      );

      expect(booking.createdAt, equals(createdTime));
    });
  });
}
