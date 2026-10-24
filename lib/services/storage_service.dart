// services/storage_service.dart
// All SharedPreferences read/write operations in one place.
// Profile, BMI history, theme, and unit preferences.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bmi_record.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class StorageService {
  StorageService._();

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  static Future<void> saveProfile(
      SharedPreferences prefs, UserProfile profile) async {
    await prefs.setString(StorageKeys.profileJson, profile.toJsonString());
  }

  static UserProfile loadProfile(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.profileJson);
    if (raw == null || raw.isEmpty) return UserProfile.empty();
    try {
      return UserProfile.fromJsonString(raw);
    } catch (_) {
      return UserProfile.empty();
    }
  }

  static Future<void> clearProfile(SharedPreferences prefs) async {
    await prefs.remove(StorageKeys.profileJson);
  }

  // ---------------------------------------------------------------------------
  // BMI History
  // ---------------------------------------------------------------------------

  static Future<void> saveHistory(
      SharedPreferences prefs, List<BmiRecord> records) async {
    final jsonStr = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(StorageKeys.bmiHistoryJson, jsonStr);
  }

  static List<BmiRecord> loadHistory(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.bmiHistoryJson);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(BmiRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearHistory(SharedPreferences prefs) async {
    await prefs.remove(StorageKeys.bmiHistoryJson);
  }

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  static Future<void> saveThemeMode(
      SharedPreferences prefs, String mode) async {
    await prefs.setString(StorageKeys.themeMode, mode);
  }

  /// Returns 'system' | 'light' | 'dark'
  static String loadThemeMode(SharedPreferences prefs) {
    return prefs.getString(StorageKeys.themeMode) ?? 'system';
  }

  // ---------------------------------------------------------------------------
  // Units
  // ---------------------------------------------------------------------------

  static Future<void> saveUseMetric(
      SharedPreferences prefs, bool useMetric) async {
    await prefs.setBool(StorageKeys.useMetric, useMetric);
  }

  /// Returns true = metric, false = imperial (default: true)
  static bool loadUseMetric(SharedPreferences prefs) {
    return prefs.getBool(StorageKeys.useMetric) ?? true;
  }
}
