import 'package:flutter/material.dart';

import '../screens/welcome_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/email_login_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/success_screen.dart';
import '../screens/create_profile_screen.dart';
import '../screens/main_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const WelcomeScreen(),
  '/signin': (context) => const SignInScreen(),
  '/login': (context) => const EmailLoginScreen(),
  '/verification': (context) => const VerificationScreen(),
  '/success': (context) => const SuccessScreen(),
  '/createProfile': (context) => const CreateProfileScreen(),
  '/home': (context) => const MainScreen(),
};
