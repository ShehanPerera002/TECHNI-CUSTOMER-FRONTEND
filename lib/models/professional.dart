import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents an available service professional.
class Professional {
  final String id;
  final String name;
  final double rating;
  final String timeToBook;
  final LatLng location;
  final String avatarUrl;
  final String phoneNumber;

  const Professional({
    required this.id,
    required this.name,
    required this.rating,
    required this.timeToBook,
    required this.location,
    required this.avatarUrl,
    required this.phoneNumber,
  });

  Professional copyWith({LatLng? location, String? timeToBook}) {
    return Professional(
      id: id,
      name: name,
      rating: rating,
      timeToBook: timeToBook ?? this.timeToBook,
      location: location ?? this.location,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
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
        String phone,
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
        phoneNumber: item.phone,
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
        phone: '+94 71 234 5678',
      ),
      (
        name: 'Sunil Santha',
        rating: 4.8,
        time: '30 min',
        lat: -_d,
        lng: _d * 1.2,
        avatar: 'https://randomuser.me/api/portraits/men/22.jpg',
        phone: '+94 77 345 6789',
      ),
      (
        name: 'Kamala Silva',
        rating: 4.5,
        time: '45 min',
        lat: _d * 0.8,
        lng: -_d * 1.5,
        avatar: 'https://randomuser.me/api/portraits/women/11.jpg',
        phone: '+94 76 456 7890',
      ),
      (
        name: 'Rohan Fernando',
        rating: 4.7,
        time: '20 min',
        lat: -_d * 1.3,
        lng: -_d * 0.5,
        avatar: 'https://randomuser.me/api/portraits/men/33.jpg',
        phone: '+94 72 567 8901',
      ),
      (
        name: 'Nimal Jayawardena',
        rating: 4.6,
        time: '25 min',
        lat: _d * 1.2,
        lng: _d * 0.3,
        avatar: 'https://randomuser.me/api/portraits/men/44.jpg',
        phone: '+94 75 678 9012',
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
        phone: '+94 71 111 2233',
      ),
      (
        name: 'Nirosha Gunawardena',
        rating: 4.7,
        time: '25 min',
        lat: -_d * 1.1,
        lng: _d * 0.8,
        avatar: 'https://randomuser.me/api/portraits/women/25.jpg',
        phone: '+94 77 222 3344',
      ),
      (
        name: 'Chandima Liyanage',
        rating: 4.8,
        time: '18 min',
        lat: _d * 0.6,
        lng: -_d * 1.2,
        avatar: 'https://randomuser.me/api/portraits/men/52.jpg',
        phone: '+94 76 333 4455',
      ),
      (
        name: 'Tharanga Dissanayake',
        rating: 4.6,
        time: '35 min',
        lat: -_d * 0.9,
        lng: -_d * 0.7,
        avatar: 'https://randomuser.me/api/portraits/men/68.jpg',
        phone: '+94 72 444 5566',
      ),
      (
        name: 'Manjula Weerasinghe',
        rating: 4.5,
        time: '40 min',
        lat: _d * 1.4,
        lng: _d * 0.5,
        avatar: 'https://randomuser.me/api/portraits/women/42.jpg',
        phone: '+94 75 555 6677',
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
        phone: '+94 71 666 7788',
      ),
      (
        name: 'Sunethra Pathirana',
        rating: 4.7,
        time: '28 min',
        lat: -_d * 0.8,
        lng: _d * 1.3,
        avatar: 'https://randomuser.me/api/portraits/women/28.jpg',
        phone: '+94 77 777 8899',
      ),
      (
        name: 'Ajith Kalubowila',
        rating: 4.9,
        time: '14 min',
        lat: _d * 0.7,
        lng: -_d * 1.0,
        avatar: 'https://randomuser.me/api/portraits/men/35.jpg',
        phone: '+94 76 888 9900',
      ),
      (
        name: 'Ruwani Siriwardena',
        rating: 4.6,
        time: '32 min',
        lat: -_d * 1.2,
        lng: -_d * 0.4,
        avatar: 'https://randomuser.me/api/portraits/women/48.jpg',
        phone: '+94 72 999 0011',
      ),
      (
        name: 'Thusitha Mendis',
        rating: 4.5,
        time: '38 min',
        lat: _d * 1.1,
        lng: _d * 0.6,
        avatar: 'https://randomuser.me/api/portraits/men/72.jpg',
        phone: '+94 75 100 1122',
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
        phone: '+94 71 200 2233',
      ),
      (
        name: 'Indika Ranasinghe',
        rating: 4.8,
        time: '22 min',
        lat: -_d * 0.95,
        lng: _d * 0.9,
        avatar: 'https://randomuser.me/api/portraits/men/47.jpg',
        phone: '+94 77 300 3344',
      ),
      (
        name: 'Nadeeka Jayasuriya',
        rating: 4.6,
        time: '30 min',
        lat: _d * 0.65,
        lng: -_d * 1.15,
        avatar: 'https://randomuser.me/api/portraits/women/31.jpg',
        phone: '+94 76 400 4455',
      ),
      (
        name: 'Kumara Senanayake',
        rating: 4.7,
        time: '26 min',
        lat: -_d * 1.15,
        lng: -_d * 0.6,
        avatar: 'https://randomuser.me/api/portraits/men/58.jpg',
        phone: '+94 72 500 5566',
      ),
      (
        name: 'Chamari Wijewardena',
        rating: 4.5,
        time: '42 min',
        lat: _d * 1.25,
        lng: _d * 0.4,
        avatar: 'https://randomuser.me/api/portraits/women/55.jpg',
        phone: '+94 75 600 6677',
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
        phone: '+94 71 700 7788',
      ),
      (
        name: 'Sajeewani Gunaratne',
        rating: 4.7,
        time: '24 min',
        lat: -_d * 0.88,
        lng: _d * 1.1,
        avatar: 'https://randomuser.me/api/portraits/women/36.jpg',
        phone: '+94 77 800 8899',
      ),
      (
        name: 'Nuwan Bandara',
        rating: 4.9,
        time: '10 min',
        lat: _d * 0.72,
        lng: -_d * 1.08,
        avatar: 'https://randomuser.me/api/portraits/men/61.jpg',
        phone: '+94 76 900 9900',
      ),
      (
        name: 'Dilhani Ekanayake',
        rating: 4.6,
        time: '34 min',
        lat: -_d * 1.08,
        lng: -_d * 0.55,
        avatar: 'https://randomuser.me/api/portraits/women/62.jpg',
        phone: '+94 72 101 0011',
      ),
      (
        name: 'Lasantha Perera',
        rating: 4.5,
        time: '40 min',
        lat: _d * 1.18,
        lng: _d * 0.45,
        avatar: 'https://randomuser.me/api/portraits/men/75.jpg',
        phone: '+94 75 202 0122',
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
        phone: '+94 71 303 0233',
      ),
      (
        name: 'Shalani Peris',
        rating: 4.7,
        time: '26 min',
        lat: -_d * 0.92,
        lng: _d * 0.84,
        avatar: 'https://randomuser.me/api/portraits/women/54.jpg',
        phone: '+94 77 404 0344',
      ),
      (
        name: 'Ravindu Hettiarachchi',
        rating: 4.8,
        time: '19 min',
        lat: _d * 0.66,
        lng: -_d * 1.1,
        avatar: 'https://randomuser.me/api/portraits/men/65.jpg',
        phone: '+94 76 505 0455',
      ),
      (
        name: 'Piumi Nisansala',
        rating: 4.6,
        time: '33 min',
        lat: -_d * 1.0,
        lng: -_d * 0.58,
        avatar: 'https://randomuser.me/api/portraits/women/41.jpg',
        phone: '+94 72 606 0566',
      ),
      (
        name: 'Sanjeewa Rodrigo',
        rating: 4.5,
        time: '41 min',
        lat: _d * 1.15,
        lng: _d * 0.48,
        avatar: 'https://randomuser.me/api/portraits/men/70.jpg',
        phone: '+94 75 707 0677',
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
        phone: '+94 71 808 0788',
      ),
      (
        name: 'Nadee Wickremasinghe',
        rating: 4.7,
        time: '27 min',
        lat: -_d * 1.05,
        lng: _d * 0.9,
        avatar: 'https://randomuser.me/api/portraits/women/64.jpg',
        phone: '+94 77 909 0899',
      ),
      (
        name: 'Malith Fernando',
        rating: 4.9,
        time: '13 min',
        lat: _d * 0.7,
        lng: -_d * 1.03,
        avatar: 'https://randomuser.me/api/portraits/men/57.jpg',
        phone: '+94 76 110 1900',
      ),
      (
        name: 'Chamodi Karunaratne',
        rating: 4.6,
        time: '31 min',
        lat: -_d * 1.1,
        lng: -_d * 0.6,
        avatar: 'https://randomuser.me/api/portraits/women/45.jpg',
        phone: '+94 72 211 2011',
      ),
      (
        name: 'Ramesh Alwis',
        rating: 4.5,
        time: '39 min',
        lat: _d * 1.2,
        lng: _d * 0.5,
        avatar: 'https://randomuser.me/api/portraits/men/73.jpg',
        phone: '+94 75 312 2122',
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
