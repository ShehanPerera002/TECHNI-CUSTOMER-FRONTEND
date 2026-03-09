import 'package:flutter/material.dart';
import '../widgets/service_search_section.dart';

/// Full service data for both list/card display and detail page.
/// Extends [ServiceItem] for search/card compatibility.
/// Pass as props to [ServiceDetailScreen].
class ServiceDetailData extends ServiceItem {
  final String pageTitle;
  final String serviceTitle;
  final String fullDescription;
  final String? imagePath;
  final String inspectionFee;
  final String hourlyRate;
  final String materials;
  final String ctaText;
  /// Hint text for the issue description field.
  final String issueHint;
  /// Example/common issues user can tap to quickly describe their problem.
  final List<String> exampleIssues;

  const ServiceDetailData({
    required IconData icon,
    required String title,
    required String description,
    required this.pageTitle,
    required this.serviceTitle,
    required this.fullDescription,
    this.imagePath,
    required this.inspectionFee,
    required this.hourlyRate,
    required this.materials,
    required this.ctaText,
    required this.issueHint,
    this.exampleIssues = const [],
  }) : super(icon, title, description);
}
