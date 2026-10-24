// providers/app_state.dart
// Central application state using ChangeNotifier + InheritedNotifier.
// No external state-management packages — pure Flutter built-ins.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bmi_record.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

// ---------------------------------------------------------------------------
// AppState — ChangeNotifier
// ---------------------------------------------------------------------------

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _useMetric = true;
  UserProfile _profile = UserProfile.empty();
  List<BmiRecord> _history = []; // newest first
  bool _isLoading = true;
  int _selectedTab = 0;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  ThemeMode get themeMode => _themeMode;
  bool get useMetric => _useMetric;
  UserProfile get profile => _profile;

  /// History sorted newest → oldest.
  List<BmiRecord> get history => _history;

  bool get isLoading => _isLoading;
  int get selectedTab => _selectedTab;

  BmiRecord? get latestRecord =>
      _history.isEmpty ? null : _history.first;

  // ---------------------------------------------------------------------------
  // Initialisation — called once at startup from main()
  // ---------------------------------------------------------------------------

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _loadTheme();
    _loadUnits();
    _loadProfile();
    _loadHistory();
    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private loaders
  // ---------------------------------------------------------------------------

  void _loadTheme() {
    final mode = StorageService.loadThemeMode(_prefs);
    _themeMode = _parseThemeMode(mode);
  }

  void _loadUnits() {
    _useMetric = StorageService.loadUseMetric(_prefs);
  }

  void _loadProfile() {
    _profile = StorageService.loadProfile(_prefs);
  }

  void _loadHistory() {
    final records = StorageService.loadHistory(_prefs);
    // Ensure newest-first ordering
    records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _history = records;
  }

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.saveThemeMode(_prefs, _themeModeString(mode));
    notifyListeners();
  }

  static ThemeMode _parseThemeMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // ---------------------------------------------------------------------------
  // Units
  // ---------------------------------------------------------------------------

  Future<void> setUseMetric(bool useMetric) async {
    _useMetric = useMetric;
    await StorageService.saveUseMetric(_prefs, useMetric);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await StorageService.saveProfile(_prefs, profile);
    notifyListeners();
  }

  Future<void> clearProfile() async {
    _profile = UserProfile.empty();
    await StorageService.clearProfile(_prefs);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // BMI History
  // ---------------------------------------------------------------------------

  Future<void> addRecord(BmiRecord record) async {
    _history = [record, ..._history];
    await StorageService.saveHistory(_prefs, _history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    await StorageService.clearHistory(_prefs);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void setSelectedTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// AppStateScope — InheritedNotifier for accessing AppState in the widget tree
// ---------------------------------------------------------------------------

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  /// Subscribes the widget to AppState changes (rebuilds on change).
  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree.');
    return scope!.notifier!;
  }

  /// Reads AppState without subscribing (does NOT rebuild on change).
  static AppState read(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree.');
    return scope!.notifier!;
  }
}
