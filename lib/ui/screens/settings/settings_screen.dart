import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName="Setting";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green,
      ),
    );
  }
}
