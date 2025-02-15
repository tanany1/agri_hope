import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth/login/login_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../utils/app_color.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  String username = "Guest";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Guest";
    });
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Hi $username",
                      style: TextStyle(
                          color: AppColors.primary4,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Image.asset(
                    "assets/img/profile.png",
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.primary5,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      "History Log",
                      style: TextStyle(
                          color: AppColors.primary4,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Image.asset(
                      "assets/img/history.png",
                      width: 50,
                      height: 50,
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
                  Navigator.pushNamed(context, SettingsScreen.routeName);
                },
                child: Row(
                  children: [
                    Text("Setting",
                        style: TextStyle(
                            color: AppColors.primary4,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Image.asset(
                      "assets/img/setting_icon.png",
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('username');
                  Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
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
                      fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
