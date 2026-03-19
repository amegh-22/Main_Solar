import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:solar/civilanapp.dart';
import 'dart:async';

import 'package:solar/login.dart';
import 'package:solar/officerweb.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _imageOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Fade animation
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _imageOpacity = 0.0);
      }
    });

    // After splash duration → check login
    Timer(const Duration(seconds: 3), () {
      _checkUser();
    });
  }

  Future<void> _checkUser() async {
    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    // If NOT logged in
    if (user == null) {
      _navigateTo(const LoginPage());
      return;
    }

    try {
      // Get role from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        _navigateTo(const LoginPage());
        return;
      }

      String role = doc['role'];

      // Role + Platform navigation
      if (role == 'officer' && kIsWeb) {
        _navigateTo(const OfficerWebPage());
      } 
      else if (role == 'civilian' && !kIsWeb) {
        _navigateTo(const CivilianAppPage());
      } 
      else {
        // Wrong platform
        _navigateTo(const LoginPage());
      }
    } catch (e) {
      _navigateTo(const LoginPage());
    }
  }

  void _navigateTo(Widget page) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _imageOpacity,
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            'assets/am.png',
            width: 200,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image, size: 100),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:solar/login.dart';
// import 'dart:async';


// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   double _imageOpacity = 1.0;

//   @override
//   void initState() {
//     super.initState();
    
//     // Start fading the logo slightly before the page transition
//     Timer(const Duration(milliseconds: 2200), () {
//       if (mounted) {
//         setState(() => _imageOpacity = 0.0);
//       }
//     });

//     // SMOOTH PAGE TRANSITION
//     Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
//             transitionsBuilder: (context, animation, secondaryAnimation, child) {
//               return FadeTransition(
//                 opacity: animation,
//                 child: child,
//               );
//             },
//             transitionDuration: const Duration(milliseconds: 1000), 
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: AnimatedOpacity(
//           opacity: _imageOpacity,
//           duration: const Duration(milliseconds: 500),
//           child: Image.asset(
//             'assets/am.png', 
//             width: 200, 
//             errorBuilder: (context, error, stackTrace) => 
//                 const Icon(Icons.image, size: 100), 
//           ),
//         ),
//       ),
//     );
//   }
// }