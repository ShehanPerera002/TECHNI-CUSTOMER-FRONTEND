import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleApiKey {
    return dotenv.env['GOOGLE_API_KEY'] ?? '';
  }

  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }
}
