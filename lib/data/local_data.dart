import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  SharedPreferences? _prefs;

  // Check if preferences are initialized
  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> setTheme(String theme) async {
    final preferences = await prefs;
    return preferences.setString('theme', theme);
  }

  Future<String> getTheme() async {
    final preferences = await prefs;
    return preferences.getString('theme') ?? 'dark';
  }
}
