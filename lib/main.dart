import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/success_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/email_login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/rating_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('[Firebase] initializeApp success');
  } on PlatformException catch (error) {
    debugPrint('[Firebase] initializeApp skipped: ${error.message}');
  } on FirebaseException catch (error) {
    debugPrint('[Firebase] initializeApp skipped: ${error.message}');
  } catch (error) {
    debugPrint('[Firebase] initializeApp unexpected error: $error');
  }

  await _requestPermissions();

  runApp(const TechniApp());
}

Future<void> _requestPermissions() async {
  try {
    await [
      Permission.microphone,
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();
  } on PlatformException catch (error) {
    debugPrint('[Permissions] request skipped: ${error.message}');
  }
}

class TechniApp extends StatelessWidget {
  const TechniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TECHNI',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/login': (context) => const EmailLoginScreen(),
        '/verification': (context) => const VerificationScreen(),
        '/success': (context) => const SuccessScreen(),
        '/createProfile': (context) => const CreateProfileScreen(),
        '/home': (context) => const MainScreen(),
        '/rating': (context) => const RatingScreen(),
      },
    );
  }
}
