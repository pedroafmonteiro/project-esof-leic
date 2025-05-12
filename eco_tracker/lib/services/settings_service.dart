import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static bool? _darkMode;
  static bool? _materialYou;
  static int? _accentColor;
  static double? _energyCost;


  static bool get darkMode => _darkMode ?? false;
  static bool get materialYou => _materialYou ?? false;
  static Color get accentColor => Color(_accentColor ?? Colors.green.value);
  static double get energyCost => _energyCost ?? 0.15;

  static Future<void> preloadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(SettingsService._darkModeKey) ?? false;
    _materialYou = prefs.getBool(SettingsService._materialYouKey) ?? false;
    _accentColor =
        prefs.getInt(SettingsService._accentColorKey) ?? Colors.green.value;
  }
}

class SettingsService extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _materialYouKey = 'materialYou';
  static const String _accentColorKey = 'accentColor';
  static const String _energyCostKey = 'energyCost';


  static const List<PredefinedColor> predefinedColors = [
    PredefinedColor(name: 'Red', color: Colors.red),
    PredefinedColor(name: 'Orange', color: Colors.orange),
    PredefinedColor(name: 'Yellow', color: Colors.yellow),
    PredefinedColor(name: 'Green', color: Colors.green),
    PredefinedColor(name: 'Cyan', color: Colors.cyan),
    PredefinedColor(name: 'Blue', color: Colors.blue),
    PredefinedColor(name: 'Purple', color: Colors.purple),
    PredefinedColor(name: 'Pink', color: Colors.pink),
  ];

  bool _darkMode = false;
  bool _materialYou = false;
  Color _accentColor = Colors.green;

  double _energyCost = 0.15;
  double get energyCost => _energyCost;

  bool get darkMode => _darkMode;
  bool get materialYou => _materialYou;
  Color get accentColor => _accentColor;

  SettingsService() {
    _darkMode = SettingsManager.darkMode;
    _materialYou = SettingsManager.materialYou;
    _accentColor = SettingsManager.accentColor;
    _energyCost = SettingsManager.energyCost;
    _loadSettings();
  }

  static Color findClosestPredefinedColor(Color color) {
    HSLColor hslColor = HSLColor.fromColor(color);
    double hue = hslColor.hue;

    if (hue < 30 || hue >= 330) {
      return Colors.red;
    } else if (hue < 65) {
      return Colors.orange;
    } else if (hue < 110) {
      return Colors.yellow;
    } else if (hue < 150) {
      return Colors.green;
    } else if (hue < 200) {
      return Colors.cyan;
    } else if (hue < 240) {
      return Colors.blue;
    } else if (hue < 290) {
      return Colors.purple;
    } else {
      return Colors.pink;
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _materialYou = prefs.getBool(_materialYouKey) ?? false;
    _accentColor = Color(prefs.getInt(_accentColorKey) ?? Colors.green.value);
    notifyListeners();
    _energyCost = prefs.getDouble(_energyCostKey) ?? 0.15;
    notifyListeners();

  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;

    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setMaterialYou(bool value) async {
    if (_materialYou == value) return;

    _materialYou = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_materialYouKey, value);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    if (_accentColor.value == color.value) return;

    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
    notifyListeners();
  }
  Future<void> setEnergyCost(double newCost) async {
    _energyCost = newCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_energyCostKey, newCost);
    notifyListeners();
  }
}

class PredefinedColor {
  final String name;
  final Color color;

  const PredefinedColor({required this.name, required this.color});
}

