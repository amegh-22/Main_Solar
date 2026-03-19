import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:solar/admin.dart';
import 'package:solar/civilanapp.dart';
import 'package:solar/officerweb.dart';
import 'package:solar/register.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // 1. Find user by username in Firestore
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _usernameController.text.trim())
        .limit(1)
        .get();

    // 2. If username not found
    if (query.docs.isEmpty) {
      throw Exception("Username not found");
    }

    final userData = query.docs.first;

    // 3. Get email
    final email = userData['email'];

    // 4. Login using Firebase Auth
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text.trim(),
    );

    // 5. Get role
    String role = userData['role'];

    if (!mounted) return;

    // 6. Platform + Role based navigation
    // Special Admin email check
if (email == "tve24mca-2012@cet.ac.in") {
  if (kIsWeb) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminUploadPage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin access only on Web")),
    );
  }
}

// Officer
else if (role == 'officer') {
  if (kIsWeb) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OfficerWebPage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Officer access only on Web")),
    );
  }
}

// Civilian
else if (role == 'civilian') {
  if (!kIsWeb) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CivilianAppPage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Civilian app available on Mobile only")),
    );
  }
}

  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Login failed")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  // // LOGIN LOGIC: Auth is now commented out
  // Future<void> _handleLogin() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     /* // 1. Check Firestore 'reg' collection for the Username
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('reg')
  //         .where('username', isEqualTo: _usernameController.text.trim())
  //         .limit(1)
  //         .get();

  //     // 2. If Username doesn't exist, show error
  //     if (querySnapshot.docs.isEmpty) {
  //       throw FirebaseAuthException(
  //         code: 'user-not-found', 
  //         message: 'This username does not exist.'
  //       );
  //     }

  //     // 3. Get the email that belongs to that username
  //     final userEmail = querySnapshot.docs.first.get('email');

  //     // 4. Sign in to Firebase Auth using that email
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: userEmail,
  //       password: _passwordController.text.trim(),
  //     );
  //     */

  //     // Temporary placeholder to simulate logic flow
  //     debugPrint("Authentication is currently disabled.");
  //     debugPrint("Username entered: ${_usernameController.text}");

  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("An error occurred. Please try again.")),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: FadeInDown(
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 7,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 80),
                        FadeInUp(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                validator: (val) => val!.isEmpty ? "Please enter your username" : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                validator: (val) => val!.isEmpty ? "Please enter your password" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade900,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Register",
                              style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}