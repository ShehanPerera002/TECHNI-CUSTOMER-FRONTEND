import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/success_screen.dart';
import 'screens/create_profile_screen.dart';

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

  runApp(const TechniApp());
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
        '/verification': (context) => const VerificationScreen(),
        '/success': (context) => const SuccessScreen(),
        '/createProfile': (context) => const CreateProfileScreen(),
      },
    );
  }
}
