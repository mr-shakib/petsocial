import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  static Future<String?> getUserId() => _storage.read(key: _userIdKey);

  static const _profilePicKey = 'profile_picture_url';

  static Future<void> saveProfilePictureUrl(String? url) =>
      _storage.write(key: _profilePicKey, value: url);

  static Future<String?> getProfilePictureUrl() =>
      _storage.read(key: _profilePicKey);

  static Future<void> clear() => _storage.deleteAll();
}
