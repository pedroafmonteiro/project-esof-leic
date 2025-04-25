import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TipsService {
  Future<List<String>> loadTips() async {
    final String response = await rootBundle.loadString('assets/tips.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }

  Future<String> getTodaysTip() async {
    List<String> tips = await loadTips();
    int index =
        DateTime.now().difference(DateTime(1970, 1, 1)).inDays % tips.length;
    return tips[index];
  }
}
