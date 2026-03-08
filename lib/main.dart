import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/success_screen.dart';
import 'screens/create_profile_screen.dart';
import 'ai_assistant/ai_welcome_screen.dart';
import 'ai_assistant/ai_analysis_screen.dart';
import 'ai_assistant/ai_checklist_screen.dart';
import 'ai_assistant/technician_match.dart';
import 'ai_assistant/ai_chat_screen.dart';

void main() {
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
