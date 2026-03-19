import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:solar/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _officerIdController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureConfirmPassword = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Reusable Input Decoration to keep code clean
  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Total length must be at least 6';
    final numRegex = RegExp(r'\d');
    if (numRegex.allMatches(value).length < 2)
      return 'Must contain at least 2 numbers';
    final specialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialRegex.hasMatch(value))
      return 'Must contain at least 1 special character';
    return null;
  }
  Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  if (_passController.text != _confirmPassController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 🔹 STEP 1: Check if username already exists
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _userController.text.trim())
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username already exists")),
      );
      setState(() => _isLoading = false);
      return;
    }

    // 🔹 STEP 2: Create user in Firebase Auth
    UserCredential userCred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
    );

    String uid = userCred.user!.uid;

    // 🔹 STEP 3: Decide role
    String role = _officerIdController.text.trim().isEmpty
        ? "civilian"
        : "officer";

    // 🔹 STEP 4: Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': _userController.text.trim(),
      'email': _emailController.text.trim(),
      'officerId': _officerIdController.text.trim(),
      'role': role,
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

//   Future<void> _handleRegister() async {
//   if (!_formKey.currentState!.validate()) return;

//   if (_passController.text != _confirmPassController.text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Passwords do not match")),
//     );
//     return;
//   }

//   setState(() => _isLoading = true);

//   try {
//     await FirebaseFirestore.instance.collection('reg').add({
//       'username': _userController.text.trim(),
//       'email': _emailController.text.trim(),
//       'officerId': _officerIdController.text.trim(),
//       'password': _passController.text.trim(),
//       'createdAt': Timestamp.now(),
//     });

//     if (!mounted) return;

//     // Optional success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("")),
//     );

//     // Clear fields
//     _userController.clear();
//     _emailController.clear();
//     _officerIdController.clear();
//     _passController.clear();
//     _confirmPassController.clear();

//     // Navigate to Login Page after short delay
//     await Future.delayed(const Duration(seconds: 1));

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//     );

//   } catch (e) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
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
            colors: [Colors.orange.shade900, Colors.orange.shade400],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 80),
              FadeInDown(
                child: const Text(
                  "REGISTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
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
                      children: [
                        const SizedBox(height: 30),
                        // Username
                        TextFormField(
                          controller: _userController,
                          decoration: _inputStyle(
                            "Username",
                            Icons.person_outline,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Enter username" : null,
                        ),
                        const SizedBox(height: 20),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputStyle(
                            "Email",
                            Icons.email_outlined,
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? "Enter valid email"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        // Officer ID
                        TextFormField(
                          controller: _officerIdController,
                          decoration: _inputStyle(
                            "Officer ID ",
                            Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          decoration: _inputStyle(
                            "Password",
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password
                        TextFormField(
                          controller: _confirmPassController,
                          obscureText: _obscureConfirmPassword,
                          validator: (v) => v != _passController.text
                              ? "Passwords do not match"
                              : null,
                          decoration: _inputStyle(
                            "Confirm Password",
                            Icons.check_circle_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        // Register Button
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade900,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "CREATE ACCOUNT",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
