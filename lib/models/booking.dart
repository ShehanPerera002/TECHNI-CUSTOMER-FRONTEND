import 'professional.dart';

enum BookingType { realTime, scheduled }

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class Booking {
  final String id;
  final String serviceTitle;
  final BookingType type;
  final BookingStatus status;
  final DateTime createdAt;
  final String? scheduledDate;
  final String? scheduledTime;
  final Professional? worker;
  final String? workerName;
  final String? workerAvatarUrl;
  final double? workerRating;

  const Booking({
    required this.id,
    required this.serviceTitle,
    required this.type,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.scheduledTime,
    this.worker,
    this.workerName,
    this.workerAvatarUrl,
    this.workerRating,
  });

  Booking copyWith({BookingStatus? status, Professional? worker}) {
    return Booking(
      id: id,
      serviceTitle: serviceTitle,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      worker: worker ?? this.worker,
      workerName: worker?.name ?? workerName,
      workerAvatarUrl: worker?.avatarUrl ?? workerAvatarUrl,
      workerRating: worker?.rating ?? workerRating,
    );
  }
}
