import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _nameKey = 'profile_name';
  static const String _mobileKey = 'profile_mobile';
  static const String _emailKey = 'profile_email';
  static const String _addressKey = 'profile_address';
  static const String _imagePathKey = 'profile_image_path';

  String _name = '';
  String _mobile = '';
  String _email = '';
  String _address = '';
  String? _imagePath;

  String get name => _name;
  String get mobile => _mobile;
  String get email => _email;
  String get address => _address;
  String? get imagePath => _imagePath;

  void setDefaults({
    required String name,
    required String mobile,
    required String email,
    required String address,
  }) {
    if (_name.isEmpty) _name = name;
    if (_mobile.isEmpty) _mobile = mobile;
    if (_email.isEmpty) _email = email;
    if (_address.isEmpty) _address = address;
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? '';
    _mobile = prefs.getString(_mobileKey) ?? '';
    _email = prefs.getString(_emailKey) ?? '';
    _address = prefs.getString(_addressKey) ?? '';
    _imagePath = prefs.getString(_imagePathKey);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _name = name;
      await prefs.setString(_nameKey, name);
    }
    if (mobile != null) {
      _mobile = mobile;
      await prefs.setString(_mobileKey, mobile);
    }
    if (email != null) {
      _email = email;
      await prefs.setString(_emailKey, email);
    }
    if (address != null) {
      _address = address;
      await prefs.setString(_addressKey, address);
    }
    if (imagePath != null) {
      _imagePath = imagePath;
      await prefs.setString(_imagePathKey, imagePath);
    }
    notifyListeners();
  }

  Future<void> setImagePath(String? path) async {
    _imagePath = path;
    if (path != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imagePathKey, path);
    }
    notifyListeners();
  }
}
