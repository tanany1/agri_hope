import 'package:flutter/material.dart';

import '../../utils/app_color.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = "Setting";

  SettingsScreen({super.key});

  final String selectedLanguage = 'English';
  final String selectedTheme = 'Light Mode';

  final List<String> languages = ['English', 'Arabic'];
  final List<String> themes = ['Light Mode', 'Dark Mode'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.primary1),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(30),
            margin: EdgeInsets.all(20),
            width: 900,
            height: 600,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: AppColors.primary1,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    // Navigate to Profile screen
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: selectedLanguage,
                    onChanged: null,
                    items: languages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Theme'),
                  trailing: DropdownButton<String>(
                    value: selectedTheme,
                    onChanged: null,
                    items: themes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
