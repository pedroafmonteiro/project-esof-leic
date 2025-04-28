import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static bool? _darkMode;

  static bool get darkMode => _darkMode ?? false;

  static Future<void> preloadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(SettingsService._darkModeKey) ?? false;
  }
}

class SettingsService extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';

  bool _darkMode = false;

  bool get darkMode => _darkMode;

  SettingsService() {
    _darkMode = SettingsManager.darkMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;

    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }
}
