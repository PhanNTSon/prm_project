import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Constants for storage keys
  static const String _keyToken = 'jwt_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'user_role';
  static const String _keyUsername = 'username';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save authentication data securely
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String role,
    required String username,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyUsername, value: username);
  }

  /// Get the JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Get the user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Get the user role
  Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  /// Get the username
  Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  /// Clear all authentication data (Logout or Token Expired)
  Future<void> clearAuthData() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyUsername);
  }
}