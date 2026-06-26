import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _textSizeKey = 'text_size';
  static const String _highContrastKey = 'high_contrast';

  bool _isDarkMode = false;
  int _textSizeLevel = 1; // 0=small, 1=medium, 2=large
  bool _highContrast = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  int get textSizeLevel => _textSizeLevel;
  bool get highContrast => _highContrast;

  double get textScaleFactor {
    switch (_textSizeLevel) {
      case 0: return 0.85;
      case 1: return 1.0;
      case 2: return 1.2;
      default: return 1.0;
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _textSizeLevel = prefs.getInt(_textSizeKey) ?? 1;
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (value == _isDarkMode) return;
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setTextSizeLevel(int level) async {
    if (level == _textSizeLevel) return;
    _textSizeLevel = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textSizeKey, level);
  }

  Future<void> setHighContrast(bool value) async {
    if (value == _highContrast) return;
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
  }

  void toggle() {
    setDarkMode(!_isDarkMode);
  }
}
