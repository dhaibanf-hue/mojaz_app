import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles dark mode and design style (Modern/Classic).
class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isModernDesign = true;
  bool get isModernDesign => _isModernDesign;

  ThemeProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Auto theme based on time if not manually set
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;
    _isDarkMode = _prefs.getBool('isDarkMode') ?? isNight;

    _isModernDesign = _prefs.getBool('isModernDesign') ?? true;

    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void toggleDesign() {
    _isModernDesign = !_isModernDesign;
    _prefs.setBool('isModernDesign', _isModernDesign);
    notifyListeners();
  }
}
