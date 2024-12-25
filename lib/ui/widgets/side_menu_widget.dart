import 'package:agri_hope/ui/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modal/user_data.dart';
import '../screens/auth/login/login_screen.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserData>(context).username;
    return Drawer(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Hi $username"),
                  Spacer(),
                  Image.asset(
                    "assets/img/profile.png",
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Text("History Log"),
                    Spacer(),
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
              color: Colors.black,
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, SettingsScreen.routeName);
                },
                child: Row(
                  children: [
                    Text("Setting"),
                    Spacer(),
                    Image.asset(
                      "assets/img/setting_icon.png",
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  } catch (e) {
                    print("Error logging out: $e");
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                // Background color,
                child: Center(
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
