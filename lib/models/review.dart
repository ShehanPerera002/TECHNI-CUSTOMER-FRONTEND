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

  String get timeAgo {
    if (daysAgo == 1) return '1 day ago';
    return '$daysAgo days ago';
  }
}
