import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkMode';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}