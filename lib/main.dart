
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import enabled
import 'package:solar/admin.dart';
import 'package:solar/civilanapp.dart';
import 'package:solar/login.dart';
import 'package:solar/officerweb.dart';
import 'package:solar/road.dart';
import 'package:solar/splash.dart';
import 'package:solar/register.dart'; // Import added
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  

  runApp(const SolarStatApp());
}





// void main() async {
//   // 1. Ensure Flutter bindings are initialized
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // 2. Initialize Firebase (Required for Firestore and Auth)
//   // Ensure you have added the google-services.json file to your android/app folder!
//   await Firebase.initializeApp();
  
//   runApp(const SolarStatApp()); // Name changed from DNAIApp
// }

class SolarStatApp extends StatelessWidget {
  const SolarStatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolarStat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Seed color changed to Orange to match your theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // The app will start with the SplashScreen
      home: const SplashScreen(),
      
      // Defining the route table for navigation
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(), // Route enabled
        '/civilianapp': (context) => const OfficerWebPage(), 
        '/officerweb': (context) => const CivilianAppPage(), 
        '/admin': (context) => const AdminUploadPage(), 
         //'/road': (context) => const RoadPage(), 
        // '/home': (context) => const HomePage(),
        // '/input': (context) => const InputPage(),
      },
    );
  }
}