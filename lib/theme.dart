import 'package:flutter/material.dart';
import 'package:ini_news_flutter/globals.dart';

class AppTheme with ChangeNotifier {
  static bool isDark = false;

  AppTheme() {
    if (themeBox!.containsKey('isDark')) {
      isDark = themeBox!.get('isDark');
    } else {
      themeBox!.put('isDark', isDark);
    }
  }

  ThemeMode currentTheme() {
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    isDark = !isDark;
    themeBox!.put('isDark', isDark);
    notifyListeners();
  }
}
