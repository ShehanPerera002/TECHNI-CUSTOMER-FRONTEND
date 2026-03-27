/// Customer review for a professional.
class Review {
  final String customerName;
  final String avatarUrl;
  final double rating;
  final int daysAgo;
  final String text;

  const Review({
    required this.customerName,
    required this.avatarUrl,
    required this.rating,
    required this.daysAgo,
    required this.text,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      customerName: json['customerName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      daysAgo: json['daysAgo'] as int,
      text: json['text'] as String,
    );
  }

  factory Review.fromFirestore(Map<String, dynamic> data) {
    final now = DateTime.now();
    final dynamic ts = data['timestamp'];
    DateTime createdAt = now;

    if (ts is DateTime) {
      createdAt = ts;
    } else if (ts is String) {
      createdAt = DateTime.tryParse(ts) ?? now;
    } else if (ts != null && ts.runtimeType.toString() == 'Timestamp') {
      // Keep this dynamic to avoid importing Firestore types in this model.
      createdAt = ts.toDate() as DateTime;
    }

    final ageDays = now.difference(createdAt).inDays;
    final reviewer = (data['reviewerName'] ?? data['customerName'] ?? 'Customer')
        .toString()
        .trim();
    final comment = (data['comment'] ?? data['text'] ?? '').toString().trim();

    return Review(
      customerName: reviewer.isEmpty ? 'Customer' : reviewer,
      avatarUrl: (data['avatarUrl'] ?? data['reviewerAvatarUrl'] ?? '').toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      daysAgo: ageDays < 0 ? 0 : ageDays,
      text: comment.isEmpty ? 'No written review.' : comment,
    );
  }

  String get timeAgo {
    if (daysAgo == 1) return '1 day ago';
    return '$daysAgo days ago';
  }
}
