import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_data.dart';

// Theme state notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalData _localData;

  ThemeNotifier(this._localData) : super(ThemeMode.dark) {
    _loadTheme();
  }

  // Load the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final themeString = await _localData.getTheme();
    state = themeString == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  // Toggle theme method
  Future<void> toggleTheme() async {
    final newTheme =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _localData.setTheme(newTheme == ThemeMode.light ? 'light' : 'dark');
    state = newTheme;
  }
}

// Provider for LocalData
final localDataProvider = Provider<LocalData>((ref) {
  return LocalData();
});

// Provider for the theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final localData = ref.watch(localDataProvider);
  return ThemeNotifier(localData);
});
