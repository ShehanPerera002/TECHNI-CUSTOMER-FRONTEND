import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/models/review.dart';

void main() {
  group('Review Model Tests', () {
    test('Review should create with correct properties', () {
      const review = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 5.0,
        daysAgo: 2,
        text: 'Excellent service!',
      );

      expect(review.customerName, equals('Ahmed'));
      expect(review.avatarUrl, equals('https://example.com/ahmed.jpg'));
      expect(review.rating, equals(5.0));
      expect(review.daysAgo, equals(2));
      expect(review.text, equals('Excellent service!'));
    });

    test('Review timeAgo should return correct format for 1 day', () {
      const review = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 5.0,
        daysAgo: 1,
        text: 'Excellent service!',
      );

      expect(review.timeAgo, equals('1 day ago'));
    });

    test('Review timeAgo should return correct format for multiple days', () {
      const review = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 5.0,
        daysAgo: 5,
        text: 'Excellent service!',
      );

      expect(review.timeAgo, equals('5 days ago'));
    });

    test('Review should create from JSON', () {
      final json = {
        'customerName': 'Ahmed',
        'avatarUrl': 'https://example.com/ahmed.jpg',
        'rating': 4.5,
        'daysAgo': 3,
        'text': 'Good service',
      };

      final review = Review.fromJson(json);

      expect(review.customerName, equals('Ahmed'));
      expect(review.avatarUrl, equals('https://example.com/ahmed.jpg'));
      expect(review.rating, equals(4.5));
      expect(review.daysAgo, equals(3));
      expect(review.text, equals('Good service'));
    });

    test('Review rating should be valid', () {
      const review = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 4.5,
        daysAgo: 2,
        text: 'Good!',
      );

      expect(review.rating >= 0, isTrue);
      expect(review.rating <= 5.0, isTrue);
    });

    test('Review should handle daysAgo correctly', () {
      const review = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 4.5,
        daysAgo: 0,
        text: 'Just now!',
      );

      expect(review.daysAgo, equals(0));
    });

    test('Review text should be a non-empty string', () {
      const review = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 4.5,
        daysAgo: 2,
        text: 'Great service, highly recommend!',
      );

      expect(review.text.isNotEmpty, isTrue);
    });

    test('Review should convert integer rating to double in JSON', () {
      final json = {
        'customerName': 'Ahmed',
        'avatarUrl': 'https://example.com/ahmed.jpg',
        'rating': 4,
        'daysAgo': 2,
        'text': 'Good',
      };

      final review = Review.fromJson(json);
      expect(review.rating, equals(4.0));
    });

    test('Review should be const and immutable', () {
      const review1 = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 4.5,
        daysAgo: 2,
        text: 'Good!',
      );

      const review2 = Review(
        customerName: 'Ahmed',
        avatarUrl: 'https://example.com/ahmed.jpg',
        rating: 4.5,
        daysAgo: 2,
        text: 'Good!',
      );

      expect(review1, equals(review2));
    });
  });
}
