import 'package:latlong2/latlong.dart';

/// Represents an available service professional.
class Professional {
  final String id;
  final String name;
  final double rating;
  final String timeToBook;
  final LatLng location;
  /// Avatar URL - uses ui-avatars.com for dummy images.
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
    const center = LatLng(6.9271, 79.8612); // Colombo
    return [
      Professional(
        id: '1',
        name: 'Saman Perera',
        rating: 4.9,
        timeToBook: '15 min',
        location: LatLng(center.latitude + 0.002, center.longitude + 0.001),
        avatarUrl: 'https://ui-avatars.com/api/?name=Saman+Perera&size=80&background=2563EB&color=fff',
      ),
      Professional(
        id: '2',
        name: 'Sunil Santha',
        rating: 4.8,
        timeToBook: '30 min',
        location: LatLng(center.latitude - 0.0015, center.longitude + 0.002),
        avatarUrl: 'https://ui-avatars.com/api/?name=Sunil+Santha&size=80&background=059669&color=fff',
      ),
      Professional(
        id: '3',
        name: 'Kamala Silva',
        rating: 4.5,
        timeToBook: '45 min',
        location: LatLng(center.latitude + 0.001, center.longitude - 0.0015),
        avatarUrl: 'https://ui-avatars.com/api/?name=Kamala+Silva&size=80&background=7C3AED&color=fff',
      ),
      Professional(
        id: '4',
        name: 'Rohan Fernando',
        rating: 4.7,
        timeToBook: '20 min',
        location: LatLng(center.latitude - 0.002, center.longitude),
        avatarUrl: 'https://ui-avatars.com/api/?name=Rohan+Fernando&size=80&background=DC2626&color=fff',
      ),
      Professional(
        id: '5',
        name: 'Nimal Jayawardena',
        rating: 4.6,
        timeToBook: '25 min',
        location: LatLng(center.latitude + 0.0015, center.longitude + 0.0025),
        avatarUrl: 'https://ui-avatars.com/api/?name=Nimal+Jayawardena&size=80&background=EA580C&color=fff',
      ),
    ];
  }

  /// Returns dummy professionals for any service category.
  static List<Professional> getDummyForCategory(String category) {
    return getDummyPlumbers();
  }
}
