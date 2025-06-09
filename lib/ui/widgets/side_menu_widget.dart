import 'package:agri_hope/ui/screens/history_log/history_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../utils/app_color.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  String username = "Guest";
  String userEmail = "";
  bool isLoading = true;

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
      // First, check if the user is currently authenticated with Firebase
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User is authenticated with Firebase Auth
        final uid = currentUser.uid;
        final email = currentUser.email;

        // Get username from Firestore using UID as document ID
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc.data()?['username'] ?? "Guest";
            userEmail = email ?? "";
          });
          return;
        } else {
          print("User document not found in Firestore for UID: $uid");
        }
      } else {
        // No Firebase Auth user, check SharedPreferences login status as fallback
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          // Try to get the UID from SharedPreferences
          final uid = prefs.getString('uid');
          final email = prefs.getString('email');

          if (uid != null && uid.isNotEmpty) {
            // Get username from Firestore using UID from SharedPreferences
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();

            if (userDoc.exists) {
              setState(() {
                username = userDoc.data()?['username'] ?? "Guest";
                userEmail = email ?? "";
              });
              return;
            }
          }

          // Fallback: If UID not available, try using email to query
          if (email != null && email.isNotEmpty) {
            // Query for the user document by email field
            final userQuery = await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

            if (userQuery.docs.isNotEmpty) {
              setState(() {
                username = userQuery.docs.first.data()['username'] ?? "Guest";
                userEmail = email;
              });
              return;
            }
          }

          // Last resort fallback to SharedPreferences
          print("Could not find user data in Firestore, using SharedPreferences");
          setState(() {
            username = prefs.getString('username') ?? "Guest";
            userEmail = email ?? "";
          });
        } else {
          // Not logged in - just use guest
          setState(() {
            username = "Guest";
            userEmail = "";
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      // Fallback to SharedPreferences if Firestore fails
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        username = prefs.getString('username') ?? "Guest";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary1,
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            isLoading
                ? CircularProgressIndicator(color: AppColors.primary4)
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Hi $username",
                style: TextStyle(
                  color: AppColors.primary4,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            if (userEmail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  userEmail,
                  style: TextStyle(
                    color: AppColors.primary4,
                    fontSize: 14,
                  ),
                ),
              ),
            Container(
              color: AppColors.primary5,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, HistoryLogScreen.routeName);
                },
                child: Row(
                  children: [
                    Text(
                      "History Log",
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.primary4,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Image.asset(
                      "assets/img/history.png",
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.primary5,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, DashboardScreen.routeName);
                },
                child: Row(
                  children: [
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 18,
                          color: AppColors.primary4,
                          fontWeight: FontWeight.bold,),
                    ),
                    const Spacer(),
                    Image.asset(
                      "assets/img/dashboard_icon.png",
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.primary5,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, ProfileScreen.routeName);
                },
                child: Row(
                  children: [
                    Text("Profile",
                        style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primary4,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Image.asset(
                      "assets/img/profile.png",
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Sign out from Firebase Auth first
                  await FirebaseAuth.instance.signOut();

                  // Then clear SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('username');
                  await prefs.remove('email');
                  await prefs.remove('uid');

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginScreen.routeName,
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print("Error logging out: $e");
                }
              },
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Center(
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}