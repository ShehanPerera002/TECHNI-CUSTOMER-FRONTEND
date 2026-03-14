import 'package:flutter/material.dart';

enum NotificationType { bookingCreated, workerAssigned, bookingCompleted, promo }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final IconData icon;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    required this.icon,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      icon: icon,
    );
  }
}
