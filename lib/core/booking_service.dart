import 'dart:math';

import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/professional.dart';

/// Singleton service that manages customer bookings, activities and notifications in-memory.
class BookingService {
  BookingService._();
  static final BookingService instance = BookingService._();

  final List<Booking> _bookings = [];
  final List<Activity> _activities = [];
  final List<AppNotification> _notifications = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Activity> get activities => List.unmodifiable(_activities);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Add a scheduled booking (from the Schedule Worker flow).
  Booking addScheduledBooking({
    required String serviceTitle,
    required String scheduledDate,
    required String scheduledTime,
  }) {
    final booking = Booking(
      id: _generateId(),
      serviceTitle: serviceTitle,
      type: BookingType.scheduled,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
    _bookings.insert(0, booking);

    _addActivity(
      title: 'Scheduled $serviceTitle',
      subtitle: '$scheduledDate at $scheduledTime',
      type: ActivityType.bookingCreated,
      icon: Icons.calendar_today,
      iconColor: const Color(0xFF2563EB),
    );

    _addNotification(
      title: 'Booking Scheduled',
      message:
          'Your $serviceTitle booking for $scheduledDate at $scheduledTime has been created.',
      type: NotificationType.bookingCreated,
      icon: Icons.calendar_today,
    );

    return booking;
  }

  /// Add a real-time booking (from the Find Worker Now flow).
  Booking addRealTimeBooking({
    required String serviceTitle,
    required Professional worker,
  }) {
    final booking = Booking(
      id: _generateId(),
      serviceTitle: serviceTitle,
      type: BookingType.realTime,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      worker: worker,
      workerName: worker.name,
      workerAvatarUrl: worker.avatarUrl,
      workerRating: worker.rating,
    );
    _bookings.insert(0, booking);

    _addActivity(
      title: 'Booked $serviceTitle',
      subtitle: '${worker.name} assigned',
      type: ActivityType.workerConfirmed,
      icon: Icons.person_pin,
      iconColor: const Color(0xFF22C55E),
    );

    _addNotification(
      title: 'Worker Assigned',
      message:
          '${worker.name} has been assigned to your $serviceTitle booking.',
      type: NotificationType.workerAssigned,
      icon: Icons.person_pin,
    );

    return booking;
  }

  /// Mark a booking as completed.
  void completeBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final b = _bookings[index];
      _bookings[index] = b.copyWith(status: BookingStatus.completed);

      _addActivity(
        title: '${b.serviceTitle} completed',
        subtitle: b.workerName != null
            ? 'Work by ${b.workerName}'
            : 'Service completed',
        type: ActivityType.workCompleted,
        icon: Icons.check_circle,
        iconColor: const Color(0xFF22C55E),
      );

      _addNotification(
        title: 'Work Completed',
        message: 'Your ${b.serviceTitle} service has been completed.',
        type: NotificationType.bookingCompleted,
        icon: Icons.check_circle,
      );
    }
  }

  /// Log a service search activity.
  void logServiceSearch(String serviceTitle) {
    _addActivity(
      title: 'Searched for $serviceTitle',
      subtitle: 'Looking for professionals',
      type: ActivityType.search,
      icon: Icons.search,
      iconColor: const Color(0xFF6B7280),
    );
  }

  /// Mark a notification as read.
  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all notifications as read.
  void markAllNotificationsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void _addActivity({
    required String title,
    required String subtitle,
    required ActivityType type,
    required IconData icon,
    required Color iconColor,
  }) {
    _activities.insert(
      0,
      Activity(
        id: _generateId(),
        title: title,
        subtitle: subtitle,
        type: type,
        createdAt: DateTime.now(),
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  void _addNotification({
    required String title,
    required String message,
    required NotificationType type,
    required IconData icon,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: _generateId(),
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        icon: icon,
      ),
    );
  }

  String _generateId() {
    final rand = Random();
    return 'BK${DateTime.now().millisecondsSinceEpoch}${rand.nextInt(999)}';
  }
}
