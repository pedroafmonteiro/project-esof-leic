import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Loads the tips from the local JSON file.
Future<List<String>> loadTips() async {
  final String response = await rootBundle.loadString('assets/tips.json');
  final List<dynamic> data = json.decode(response);
  return data.cast<String>();
}

/// Gets the tip of the day based on the current date.
Future<String> getTodaysTip() async {
  List<String> tips = await loadTips();
  int index = DateTime.now().difference(DateTime(2025, 1, 1)).inDays % tips.length;
  return tips[index];
}
