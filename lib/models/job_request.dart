import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JobRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? workerId;
  final String status;
  final String jobType;
  final String? description;
  final LatLng customerLocation;
  final LatLng? workerLocation;
  final List<String> notifiedWorkerIds;
  final List<String> rejectedWorkerIds;
  final double? fare;
  final int? duration;
  final DateTime createdAt;
  final DateTime? workerAcceptedAt;
  final DateTime? customerConfirmedAt;
  final DateTime? jobStartedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;

  JobRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.workerId,
    required this.status,
    required this.jobType,
    this.description,
    required this.customerLocation,
    this.workerLocation,
    this.notifiedWorkerIds = const [],
    this.rejectedWorkerIds = const [],
    this.fare,
    this.duration,
    required this.createdAt,
    this.workerAcceptedAt,
    this.customerConfirmedAt,
    this.jobStartedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
  });

  factory JobRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    LatLng parseGeoPoint(dynamic field) {
      if (field is GeoPoint) return LatLng(field.latitude, field.longitude);
      return const LatLng(0, 0);
    }
    
    DateTime parseTimestamp(dynamic field) {
      if (field is Timestamp) return field.toDate();
      if (field is String) return DateTime.tryParse(field) ?? DateTime.now();
      return DateTime.now();
    }
    
    DateTime? parseNullableTimestamp(dynamic field) {
      if (field == null) return null;
      if (field is Timestamp) return field.toDate();
      if (field is String) return DateTime.tryParse(field);
      return null;
    }

    return JobRequest(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'],
      workerId: data['workerId'],
      status: data['status'] ?? 'searching',
      jobType: data['jobType'] ?? '',
      description: data['description'],
      customerLocation: parseGeoPoint(data['customerLocation']),
      workerLocation: data['workerLocation'] != null ? parseGeoPoint(data['workerLocation']) : null,
      notifiedWorkerIds: List<String>.from(data['notifiedWorkerIds'] ?? []),
      rejectedWorkerIds: List<String>.from(data['rejectedWorkerIds'] ?? []),
      fare: (data['fare'] as num?)?.toDouble(),
      duration: data['duration'] as int?,
      createdAt: parseTimestamp(data['createdAt']),
      workerAcceptedAt: parseNullableTimestamp(data['workerAcceptedAt']),
      customerConfirmedAt: parseNullableTimestamp(data['customerConfirmedAt']),
      jobStartedAt: parseNullableTimestamp(data['jobStartedAt']),
      completedAt: parseNullableTimestamp(data['completedAt']),
      cancelledAt: parseNullableTimestamp(data['cancelledAt']),
      cancelReason: data['cancelReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'workerId': workerId,
      'status': status,
      'jobType': jobType,
      'description': description,
      'customerLocation': GeoPoint(customerLocation.latitude, customerLocation.longitude),
      'workerLocation': workerLocation != null ? GeoPoint(workerLocation!.latitude, workerLocation!.longitude) : null,
      'notifiedWorkerIds': notifiedWorkerIds,
      'rejectedWorkerIds': rejectedWorkerIds,
      'fare': fare,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'workerAcceptedAt': workerAcceptedAt != null ? Timestamp.fromDate(workerAcceptedAt!) : null,
      'customerConfirmedAt': customerConfirmedAt != null ? Timestamp.fromDate(customerConfirmedAt!) : null,
      'jobStartedAt': jobStartedAt != null ? Timestamp.fromDate(jobStartedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancelReason': cancelReason,
    };
  }
}
