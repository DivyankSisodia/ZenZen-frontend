import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<bool> setLanguage(String language) async {
    final preferences = await prefs;
    return preferences.setString('language', language);
  }

  Future<String> getCurrentUserId() async {
    final preferences = await prefs;
    return preferences.getString('currentUserId') ?? '';
  }
}

class TokenManager {
  // Make it a singleton
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken, 
    required String refreshToken
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);

    } catch (e) {
      print('❌ Token Save Error: $e');
    }
  }

  // Add a method to read tokens for debugging
  Future<void> debugTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    
    print('🕵️ Debug Tokens:');
    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}