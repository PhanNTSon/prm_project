import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  // Constants for storage keys
  static const String _keyToken = 'jwt_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'user_role';
  static const String _keyUsername = 'username';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Save authentication data securely (using SharedPreferences for simplicity and reliability)
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String role,
    required String username,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyUsername, username);
  }

  /// Get the JWT token
  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyToken);
  }

  /// Get the user ID
  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserId);
  }

  /// Get the user role
  Future<String?> getRole() async {
    final prefs = await _prefs;
    return prefs.getString(_keyRole);
  }

  /// Get the username
  Future<String?> getUsername() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUsername);
  }

  /// Clear all authentication data (Logout or Token Expired)
  Future<void> clearAuthData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUsername);
  }
}