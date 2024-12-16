import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  String _username = '';

  String get username => _username;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  Future<void> loadUsernameFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }
}