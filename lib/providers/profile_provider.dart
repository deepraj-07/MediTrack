import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _nameKey = 'profile_name';
  static const String _mobileKey = 'profile_mobile';
  static const String _emailKey = 'profile_email';
  static const String _addressKey = 'profile_address';
  static const String _imagePathKey = 'profile_image_path';
  // New keys for additional profile fields
  static const String _dobKey = 'profile_dob';
  static const String _genderKey = 'profile_gender';
  static const String _bloodGroupKey = 'profile_blood_group';

  String _name = '';
  String _mobile = '';
  String _email = '';
  String _address = '';
  String? _imagePath;
  // New profile fields
  String _dob = '';
  String _gender = '';
  String _bloodGroup = '';

  String get name => _name;
  String get mobile => _mobile;
  String get email => _email;
  String get address => _address;
  String? get imagePath => _imagePath;
  // New getters
  String get dob => _dob;
  String get gender => _gender;
  String get bloodGroup => _bloodGroup;

  void setDefaults({
    required String name,
    required String mobile,
    required String email,
    required String address,
  }) {
    bool changed = false;
    if (_name.isEmpty) {
      _name = name;
      changed = true;
    }
    if (_mobile.isEmpty) {
      _mobile = mobile;
      changed = true;
    }
    if (_email.isEmpty) {
      _email = email;
      changed = true;
    }
    if (_address.isEmpty) {
      _address = address;
      changed = true;
    }
    if (changed) notifyListeners();
  }


  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? _name;
    _mobile = prefs.getString(_mobileKey) ?? _mobile;
    _email = prefs.getString(_emailKey) ?? _email;
    _address = prefs.getString(_addressKey) ?? _address;
    _imagePath = prefs.getString(_imagePathKey) ?? _imagePath;
    // Load new fields
    _dob = prefs.getString(_dobKey) ?? _dob;
    _gender = prefs.getString(_genderKey) ?? _gender;
    _bloodGroup = prefs.getString(_bloodGroupKey) ?? _bloodGroup;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? imagePath,
    // New optional fields
    String? dob,
    String? gender,
    String? bloodGroup,
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
    // Handle new fields
    if (dob != null) {
      _dob = dob;
      await prefs.setString(_dobKey, dob);
    }
    if (gender != null) {
      _gender = gender;
      await prefs.setString(_genderKey, gender);
    }
    if (bloodGroup != null) {
      _bloodGroup = bloodGroup;
      await prefs.setString(_bloodGroupKey, bloodGroup);
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
