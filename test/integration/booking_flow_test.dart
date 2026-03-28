import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/models/booking.dart';
import 'package:technni_customer/models/professional.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('Booking Flow Integration Tests', () {
    test('Booking flow: Create booking with real-time service', () {
      // Step 1: Create a booking
      final booking = Booking(
        id: 'booking_001',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26, 10, 0),
      );

      expect(booking.status, equals(BookingStatus.pending));
      expect(booking.type, equals(BookingType.realTime));

      // Step 2: Find and assign a professional
      final professional = Professional(
        id: 'prof_001',
        name: 'John Plumber',
        rating: 4.8,
        timeToBook: '10 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
        isAvailable: true,
      );

      expect(professional.isAvailable, isTrue);

      // Step 3: Confirm the booking with professional
      final confirmedBooking = booking.copyWith(
        status: BookingStatus.confirmed,
        worker: professional,
      );

      expect(confirmedBooking.status, equals(BookingStatus.confirmed));
      expect(confirmedBooking.worker, equals(professional));
      expect(confirmedBooking.workerName, equals('John Plumber'));
    });

    test('Booking flow: Complete real-time booking workflow', () {
      // Step 1: Create booking
      var booking = Booking(
        id: 'booking_002',
        serviceTitle: 'AC Repair',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26, 14, 0),
      );

      expect(booking.status, equals(BookingStatus.pending));

      // Step 2: Confirm booking
      booking = booking.copyWith(status: BookingStatus.confirmed);
      expect(booking.status, equals(BookingStatus.confirmed));

      // Step 3: Start job
      booking = booking.copyWith(status: BookingStatus.inProgress);
      expect(booking.status, equals(BookingStatus.inProgress));

      // Step 4: Complete job
      booking = booking.copyWith(status: BookingStatus.completed);
      expect(booking.status, equals(BookingStatus.completed));
    });

    test('Booking flow: Schedule a booking for future date', () {
      final booking = Booking(
        id: 'booking_003',
        serviceTitle: 'Painting',
        type: BookingType.scheduled,
        status: BookingStatus.confirmed,
        createdAt: DateTime(2024, 3, 26),
        scheduledDate: '2024-03-28',
        scheduledTime: '10:00 AM',
      );

      expect(booking.type, equals(BookingType.scheduled));
      expect(booking.scheduledDate, equals('2024-03-28'));
      expect(booking.scheduledTime, equals('10:00 AM'));
      expect(booking.status, equals(BookingStatus.confirmed));
    });

    test('Booking flow: Cancel booking before confirmation', () {
      var booking = Booking(
        id: 'booking_004',
        serviceTitle: 'Carpentry',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26, 15, 0),
      );

      expect(booking.status, equals(BookingStatus.pending));

      // Cancel before confirmation
      booking = booking.copyWith(status: BookingStatus.cancelled);
      expect(booking.status, equals(BookingStatus.cancelled));
    });

    test('Booking flow: Multiple bookings in sequence', () {
      List<Booking> bookings = [];
      final services = ['Plumbing', 'Electrical', 'AC Repair'];

      for (int i = 0; i < services.length; i++) {
        final booking = Booking(
          id: 'booking_00${i + 1}',
          serviceTitle: services[i],
          type: BookingType.realTime,
          status: BookingStatus.pending,
          createdAt: DateTime(2024, 3, 26, 9 + i),
        );
        bookings.add(booking);
      }

      expect(bookings.length, equals(3));
      for (var booking in bookings) {
        expect(booking.status, equals(BookingStatus.pending));
      }
    });

    test('Booking flow: Assign professional and update booking', () {
      var booking = Booking(
        id: 'booking_005',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26, 11, 0),
      );

      // Assign first professional
      final prof1 = Professional(
        id: 'prof_001',
        name: 'John',
        rating: 4.5,
        timeToBook: '15 mins',
        location: const LatLng(25.2048, 55.2708),
        avatarUrl: 'https://example.com/john.jpg',
        phoneNumber: '0501234567',
      );

      booking = booking.copyWith(worker: prof1);
      expect(booking.workerName, equals('John'));

      // Switch to different professional
      final prof2 = Professional(
        id: 'prof_002',
        name: 'Ahmed',
        rating: 4.8,
        timeToBook: '12 mins',
        location: const LatLng(25.2050, 55.2710),
        avatarUrl: 'https://example.com/ahmed.jpg',
        phoneNumber: '0501234568',
      );

      booking = booking.copyWith(worker: prof2);
      expect(booking.workerName, equals('Ahmed'));
      expect(booking.workerRating, equals(4.8));
    });

    test('Booking flow: Verify immutability of booking data', () {
      final originalBooking = Booking(
        id: 'booking_006',
        serviceTitle: 'Cleaning',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26, 12, 0),
      );

      final modifiedBooking = originalBooking.copyWith(
        status: BookingStatus.confirmed,
      );

      // Original booking should not be modified
      expect(originalBooking.status, equals(BookingStatus.pending));
      expect(modifiedBooking.status, equals(BookingStatus.confirmed));
    });

    test('Booking flow: Track booking state transitions', () {
      var booking = Booking(
        id: 'booking_007',
        serviceTitle: 'Plumbing',
        type: BookingType.realTime,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 3, 26, 16, 0),
      );

      final stateTransitions = <BookingStatus>[];
      stateTransitions.add(booking.status);

      // Transit through states
      booking = booking.copyWith(status: BookingStatus.confirmed);
      stateTransitions.add(booking.status);

      booking = booking.copyWith(status: BookingStatus.inProgress);
      stateTransitions.add(booking.status);

      booking = booking.copyWith(status: BookingStatus.completed);
      stateTransitions.add(booking.status);

      expect(stateTransitions.length, equals(4));
      expect(stateTransitions[0], equals(BookingStatus.pending));
      expect(stateTransitions[1], equals(BookingStatus.confirmed));
      expect(stateTransitions[2], equals(BookingStatus.inProgress));
      expect(stateTransitions[3], equals(BookingStatus.completed));
    });
  });
}
