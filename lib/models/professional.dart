import 'package:latlong2/latlong.dart';

/// Represents an available service professional.
class Professional {
  final String id;
  final String name;
  final double rating;
  final String timeToBook;
  final LatLng location;
  /// Avatar URL - uses randomuser.me for male/female face portraits.
  final String avatarUrl;

  const Professional({
    required this.id,
    required this.name,
    required this.rating,
    required this.timeToBook,
    required this.location,
    required this.avatarUrl,
  });

  static List<Professional> getDummyPlumbers() {
    const center = LatLng(6.9271, 79.8612); // Colombo - user location
    const d = 0.004; // ~450m spacing so avatars spread across the map
    return [
      Professional(
        id: '1',
        name: 'Saman Perera',
        rating: 4.9,
        timeToBook: '15 min',
        location: LatLng(center.latitude + d, center.longitude + d),
        avatarUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
      ),
      Professional(
        id: '2',
        name: 'Sunil Santha',
        rating: 4.8,
        timeToBook: '30 min',
        location: LatLng(center.latitude - d, center.longitude + d * 1.2),
        avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      ),
      Professional(
        id: '3',
        name: 'Kamala Silva',
        rating: 4.5,
        timeToBook: '45 min',
        location: LatLng(center.latitude + d * 0.8, center.longitude - d * 1.5),
        avatarUrl: 'https://randomuser.me/api/portraits/women/11.jpg',
      ),
      Professional(
        id: '4',
        name: 'Rohan Fernando',
        rating: 4.7,
        timeToBook: '20 min',
        location: LatLng(center.latitude - d * 1.3, center.longitude - d * 0.5),
        avatarUrl: 'https://randomuser.me/api/portraits/men/33.jpg',
      ),
      Professional(
        id: '5',
        name: 'Nimal Jayawardena',
        rating: 4.6,
        timeToBook: '25 min',
        location: LatLng(center.latitude + d * 1.2, center.longitude + d * 0.3),
        avatarUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
      ),
    ];
  }

  /// Returns dummy professionals for any service category.
  static List<Professional> getDummyForCategory(String category) {
    return getDummyPlumbers();
  }
}
