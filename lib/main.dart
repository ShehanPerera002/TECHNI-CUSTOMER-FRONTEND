import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/session_manager.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/success_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/email_login_screen.dart';
import 'screens/main_screen.dart';
import 'ai_assistant/ai_welcome_screen.dart';
import 'ai_assistant/ai_analysis_screen.dart';
import 'ai_assistant/ai_checklist_screen.dart';
import 'ai_assistant/technician_match.dart';
import 'ai_assistant/ai_chat_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/find_professional_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  debugPrint('[ENV] GEMINI_API_KEY loaded: ${dotenv.env['GEMINI_API_KEY'] != null}');

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
  await SessionManager.initialize();

  // Force logout on app restart to ensure it "FIRSTLY WELCOME SCREEN AND CUSTOMER NEED TO LOG AND AUTHENTICATE"
  await FirebaseAuth.instance.signOut();
  SessionManager.clear();

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

  static const Map<String, String> _serviceRoutes = {
    '/find_plumber': 'Plumbing Services',
    '/find_electrician': 'Electrical Services',
    '/find_carpenter': 'Carpentry Services',
    '/find_gardener': 'Gardening Services',
    '/find_painter': 'Painting Services',
    '/find_ac_tech': 'AC Services',
    '/find_elv': 'ELV Services',
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TECHNI',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SessionGateScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/login': (context) => const EmailLoginScreen(),
        '/verification': (context) => const VerificationScreen(),
        '/success': (context) => const SuccessScreen(),
        '/createProfile': (context) => const CreateProfileScreen(),
        '/home': (context) => const MainScreen(),
        '/ai': (context) => const AIWelcomeScreen(),
        '/chat': (context) => const AIChatScreen(),
        '/analysis': (context) => const AiAnalysisScreen(),
        '/checklist': (context) => const AiChecklistScreen(),
        '/technician': (context) => const TechnicianMatchScreen(),
        '/rating': (context) => const RatingScreen(),

      },
      onGenerateRoute: (settings) {
        final routeName = settings.name;
        if (routeName != null && _serviceRoutes.containsKey(routeName)) {
          final issueDescription = settings.arguments is String
              ? settings.arguments as String
              : null;
          return MaterialPageRoute(
            builder: (_) => FindProfessionalScreen(
              serviceTitle: _serviceRoutes[routeName]!,
              issueDescription: issueDescription,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class SessionGateScreen extends StatelessWidget {
  const SessionGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (SessionManager.customerDocId == null ||
          SessionManager.customerDocId!.trim().isEmpty) {
        SessionManager.setCustomerDocId(user.uid);
      }
      return const MainScreen();
    }

    if (SessionManager.hasSession) {
      return const MainScreen();
    }

    return const WelcomeScreen();
  }
}
