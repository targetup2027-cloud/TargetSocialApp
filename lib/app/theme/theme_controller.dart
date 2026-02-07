import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/social/application/posts_controller.dart';

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeController(prefs);
});

class ThemeController extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _themeKey = 'theme_mode';

  ThemeController(this._prefs) : super(_loadThemeFromPrefs(_prefs));

  static ThemeMode _loadThemeFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString(_themeKey);
    return saved == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    _prefs.setString(_themeKey, newMode == ThemeMode.light ? 'light' : 'dark');
  }
}
