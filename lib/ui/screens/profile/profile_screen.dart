import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/app_color.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  bool obscurePassword = true;
  bool isGuest = false;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if user is guest
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.isAnonymous) {
        setState(() {
          isGuest = true;
          usernameController.text = "guest";
          emailController.text = "guest";
          passwordController.text = "guest";
        });
        return;
      }

      // Get currently logged in user
      userId = currentUser.uid;
      emailController.text = currentUser.email ?? "";

      // Get username from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('password') ?? "********";

      if (userDoc.exists) {
        setState(() {
          usernameController.text = userDoc.data()?['username'] ?? "";
          passwordController.text = obscurePassword ? "********" : storedPassword;
        });
      } else {
        setState(() {
          usernameController.text = "";
          passwordController.text = obscurePassword ? "********" : storedPassword;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        usernameController.text = "";
        emailController.text = "";
        passwordController.text = obscurePassword ? "********" : "Error retrieving password";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.all(20),
            width: 900,
            height: 600,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: AppColors.primary1,
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "User Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Avatar placeholder
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary5,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: AppColors.primary2,
                  ),
                ),
                const SizedBox(height: 40),
                // Username field (read-only)
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.primary5,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Email field (read-only)
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.primary5,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password field (read-only) with toggle visibility
                TextField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                          if (!obscurePassword) {
                            _loadActualPassword();
                          }
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.primary5,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isGuest ? Colors.orange : AppColors.primary2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isGuest ? "Guest Mode" : "Logged In",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadActualPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('password') ?? "No password stored";
      setState(() {
        passwordController.text = storedPassword;
      });
    } catch (e) {
      print("Error loading actual password: $e");
      setState(() {
        passwordController.text = "Error retrieving password";
      });
    }
  }
}