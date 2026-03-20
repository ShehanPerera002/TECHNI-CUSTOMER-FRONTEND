import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const int _port = 5000;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }

    // Android emulator cannot reach host machine through localhost.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port/api';
    }

    return 'http://localhost:$_port/api';
  }
}
