import 'package:flutter/material.dart';

enum ActivityType { search, bookingCreated, workerConfirmed, workCompleted }

class Activity {
  final String id;
  final String title;
  final String subtitle;
  final ActivityType type;
  final DateTime createdAt;
  final IconData icon;
  final Color iconColor;

  const Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
  });
}
