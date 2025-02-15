import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  String _username = 'Guest'; // Default to Guest

  String get username => _username;

  void setUsername(String username) async {
    _username = username;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
  }

  Future<void> loadUsernameFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? 'Guest';
    notifyListeners();
  }
}
