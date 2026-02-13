import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager with ChangeNotifier {
  static final PreferenceManager _instance = PreferenceManager._internal();
  factory PreferenceManager() {
    return _instance;
  }
  static late final SharedPreferences _preferences;
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  PreferenceManager._internal();
  static Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  static String? getString(String key) {
    return _preferences.getString(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  static int? getInt(String key) {
    return _preferences.getInt(key);
  }

  static double? getDouble(String key) {
    final value = _preferences.get(key);
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return null;
  }

  static Future<bool> remove(String key) {
    return _preferences.remove(key);
  }

  static bool? getbool(String key) {
    return _preferences.getBool(key);
  }

  static void clear() {
    _preferences.clear();
  }
}
