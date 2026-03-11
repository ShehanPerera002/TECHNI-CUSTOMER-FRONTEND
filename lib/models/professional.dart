import 'package:latlong2/latlong.dart';

/// Represents an available service professional.
class Professional {
  final String id;
  final String name;
  final double rating;
  final String timeToBook;
  final LatLng location;
  final String avatarUrl;

  const Professional({
    required this.id,
    required this.name,
    required this.rating,
    required this.timeToBook,
    required this.location,
    required this.avatarUrl,
  });

  Professional copyWith({LatLng? location, String? timeToBook}) {
    return Professional(
      id: id,
      name: name,
      rating: rating,
      timeToBook: timeToBook ?? this.timeToBook,
      location: location ?? this.location,
      avatarUrl: avatarUrl,
    );
  }

  static const _center = LatLng(6.9271, 79.8612);
  static const _d = 0.004;

  static List<Professional> _makeList(
    String prefix,
    List<
      ({
        String name,
        double rating,
        String time,
        double lat,
        double lng,
        String avatar,
      })
    >
    items,
  ) {
    return items.asMap().entries.map((e) {
      final i = e.key + 1;
      final item = e.value;
      return Professional(
        id: '$prefix-$i',
        name: item.name,
        rating: item.rating,
        timeToBook: item.time,
        location: LatLng(
          _center.latitude + item.lat,
          _center.longitude + item.lng,
        ),
        avatarUrl: item.avatar,
      );
    }).toList();
  }

  static List<Professional> getDummyPlumbers() {
    return _makeList('plumber', [
      (
        name: 'Saman Perera',
        rating: 4.9,
        time: '15 min',
        lat: _d,
        lng: _d,
        avatar: 'https://randomuser.me/api/portraits/men/11.jpg',
      ),
      (
        name: 'Sunil Santha',
        rating: 4.8,
        time: '30 min',
        lat: -_d,
        lng: _d * 1.2,
        avatar: 'https://randomuser.me/api/portraits/men/22.jpg',
      ),
      (
        name: 'Kamala Silva',
        rating: 4.5,
        time: '45 min',
        lat: _d * 0.8,
        lng: -_d * 1.5,
        avatar: 'https://randomuser.me/api/portraits/women/11.jpg',
      ),
      (
        name: 'Rohan Fernando',
        rating: 4.7,
        time: '20 min',
        lat: -_d * 1.3,
        lng: -_d * 0.5,
        avatar: 'https://randomuser.me/api/portraits/men/33.jpg',
      ),
      (
        name: 'Nimal Jayawardena',
        rating: 4.6,
        time: '25 min',
        lat: _d * 1.2,
        lng: _d * 0.3,
        avatar: 'https://randomuser.me/api/portraits/men/44.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyElectricians() {
    return _makeList('electrician', [
      (
        name: 'Dilshan Abeywickrama',
        rating: 4.9,
        time: '12 min',
        lat: _d * 0.9,
        lng: _d * 1.1,
        avatar: 'https://randomuser.me/api/portraits/men/15.jpg',
      ),
      (
        name: 'Nirosha Gunawardena',
        rating: 4.7,
        time: '25 min',
        lat: -_d * 1.1,
        lng: _d * 0.8,
        avatar: 'https://randomuser.me/api/portraits/women/25.jpg',
      ),
      (
        name: 'Chandima Liyanage',
        rating: 4.8,
        time: '18 min',
        lat: _d * 0.6,
        lng: -_d * 1.2,
        avatar: 'https://randomuser.me/api/portraits/men/52.jpg',
      ),
      (
        name: 'Tharanga Dissanayake',
        rating: 4.6,
        time: '35 min',
        lat: -_d * 0.9,
        lng: -_d * 0.7,
        avatar: 'https://randomuser.me/api/portraits/men/68.jpg',
      ),
      (
        name: 'Manjula Weerasinghe',
        rating: 4.5,
        time: '40 min',
        lat: _d * 1.4,
        lng: _d * 0.5,
        avatar: 'https://randomuser.me/api/portraits/women/42.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyGardeners() {
    return _makeList('gardener', [
      (
        name: 'Bandula Wickramaratne',
        rating: 4.8,
        time: '20 min',
        lat: _d * 1.0,
        lng: _d * 0.9,
        avatar: 'https://randomuser.me/api/portraits/men/18.jpg',
      ),
      (
        name: 'Sunethra Pathirana',
        rating: 4.7,
        time: '28 min',
        lat: -_d * 0.8,
        lng: _d * 1.3,
        avatar: 'https://randomuser.me/api/portraits/women/28.jpg',
      ),
      (
        name: 'Ajith Kalubowila',
        rating: 4.9,
        time: '14 min',
        lat: _d * 0.7,
        lng: -_d * 1.0,
        avatar: 'https://randomuser.me/api/portraits/men/35.jpg',
      ),
      (
        name: 'Ruwani Siriwardena',
        rating: 4.6,
        time: '32 min',
        lat: -_d * 1.2,
        lng: -_d * 0.4,
        avatar: 'https://randomuser.me/api/portraits/women/48.jpg',
      ),
      (
        name: 'Thusitha Mendis',
        rating: 4.5,
        time: '38 min',
        lat: _d * 1.1,
        lng: _d * 0.6,
        avatar: 'https://randomuser.me/api/portraits/men/72.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyCarpenters() {
    return _makeList('carpenter', [
      (
        name: 'Asela Herath',
        rating: 4.9,
        time: '16 min',
        lat: _d * 0.85,
        lng: _d * 1.05,
        avatar: 'https://randomuser.me/api/portraits/men/21.jpg',
      ),
      (
        name: 'Indika Ranasinghe',
        rating: 4.8,
        time: '22 min',
        lat: -_d * 0.95,
        lng: _d * 0.9,
        avatar: 'https://randomuser.me/api/portraits/men/47.jpg',
      ),
      (
        name: 'Nadeeka Jayasuriya',
        rating: 4.6,
        time: '30 min',
        lat: _d * 0.65,
        lng: -_d * 1.15,
        avatar: 'https://randomuser.me/api/portraits/women/31.jpg',
      ),
      (
        name: 'Kumara Senanayake',
        rating: 4.7,
        time: '26 min',
        lat: -_d * 1.15,
        lng: -_d * 0.6,
        avatar: 'https://randomuser.me/api/portraits/men/58.jpg',
      ),
      (
        name: 'Chamari Wijewardena',
        rating: 4.5,
        time: '42 min',
        lat: _d * 1.25,
        lng: _d * 0.4,
        avatar: 'https://randomuser.me/api/portraits/women/55.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyPainters() {
    return _makeList('painter', [
      (
        name: 'Roshan Premaratne',
        rating: 4.8,
        time: '18 min',
        lat: _d * 0.92,
        lng: _d * 0.98,
        avatar: 'https://randomuser.me/api/portraits/men/24.jpg',
      ),
      (
        name: 'Sajeewani Gunaratne',
        rating: 4.7,
        time: '24 min',
        lat: -_d * 0.88,
        lng: _d * 1.1,
        avatar: 'https://randomuser.me/api/portraits/women/36.jpg',
      ),
      (
        name: 'Nuwan Bandara',
        rating: 4.9,
        time: '10 min',
        lat: _d * 0.72,
        lng: -_d * 1.08,
        avatar: 'https://randomuser.me/api/portraits/men/61.jpg',
      ),
      (
        name: 'Dilhani Ekanayake',
        rating: 4.6,
        time: '34 min',
        lat: -_d * 1.08,
        lng: -_d * 0.55,
        avatar: 'https://randomuser.me/api/portraits/women/62.jpg',
      ),
      (
        name: 'Lasantha Perera',
        rating: 4.5,
        time: '40 min',
        lat: _d * 1.18,
        lng: _d * 0.45,
        avatar: 'https://randomuser.me/api/portraits/men/75.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyACTechnicians() {
    return _makeList('ac-tech', [
      (
        name: 'Kasun Maduranga',
        rating: 4.9,
        time: '14 min',
        lat: _d * 0.94,
        lng: _d * 1.06,
        avatar: 'https://randomuser.me/api/portraits/men/12.jpg',
      ),
      (
        name: 'Shalani Peris',
        rating: 4.7,
        time: '26 min',
        lat: -_d * 0.92,
        lng: _d * 0.84,
        avatar: 'https://randomuser.me/api/portraits/women/54.jpg',
      ),
      (
        name: 'Ravindu Hettiarachchi',
        rating: 4.8,
        time: '19 min',
        lat: _d * 0.66,
        lng: -_d * 1.1,
        avatar: 'https://randomuser.me/api/portraits/men/65.jpg',
      ),
      (
        name: 'Piumi Nisansala',
        rating: 4.6,
        time: '33 min',
        lat: -_d * 1.0,
        lng: -_d * 0.58,
        avatar: 'https://randomuser.me/api/portraits/women/41.jpg',
      ),
      (
        name: 'Sanjeewa Rodrigo',
        rating: 4.5,
        time: '41 min',
        lat: _d * 1.15,
        lng: _d * 0.48,
        avatar: 'https://randomuser.me/api/portraits/men/70.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyELVRepairers() {
    return _makeList('elv', [
      (
        name: 'Ishara De Silva',
        rating: 4.8,
        time: '16 min',
        lat: _d * 0.88,
        lng: _d * 1.0,
        avatar: 'https://randomuser.me/api/portraits/men/16.jpg',
      ),
      (
        name: 'Nadee Wickremasinghe',
        rating: 4.7,
        time: '27 min',
        lat: -_d * 1.05,
        lng: _d * 0.9,
        avatar: 'https://randomuser.me/api/portraits/women/64.jpg',
      ),
      (
        name: 'Malith Fernando',
        rating: 4.9,
        time: '13 min',
        lat: _d * 0.7,
        lng: -_d * 1.03,
        avatar: 'https://randomuser.me/api/portraits/men/57.jpg',
      ),
      (
        name: 'Chamodi Karunaratne',
        rating: 4.6,
        time: '31 min',
        lat: -_d * 1.1,
        lng: -_d * 0.6,
        avatar: 'https://randomuser.me/api/portraits/women/45.jpg',
      ),
      (
        name: 'Ramesh Alwis',
        rating: 4.5,
        time: '39 min',
        lat: _d * 1.2,
        lng: _d * 0.5,
        avatar: 'https://randomuser.me/api/portraits/men/73.jpg',
      ),
    ]);
  }

  static List<Professional> getDummyForCategory(String serviceTitle) {
    switch (serviceTitle) {
      case 'Plumbing Services':
        return getDummyPlumbers();
      case 'Electrical Services':
        return getDummyElectricians();
      case 'Gardening Services':
        return getDummyGardeners();
      case 'Carpentry Services':
        return getDummyCarpenters();
      case 'Painting Services':
        return getDummyPainters();
      case 'AC Services':
        return getDummyACTechnicians();
      case 'ELV Services':
        return getDummyELVRepairers();
      default:
        return getDummyPlumbers();
    }
  }
}
