import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  static const _userId = "user_id";
  static const _loggedIn = "logged_in";
  static const _fcmToken = "fcm_token";

  static Future<void> saveUser(int userId) async {
    await _storage.write(key: _userId, value: userId.toString());
    await _storage.write(key: _loggedIn, value: "true");
  }

  static Future<int?> getUserId() async {
    final value = await _storage.read(key: _userId);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _loggedIn);
    return value == "true";
  }

  static Future<void> saveFCMToken(String token) async {
    await _storage.write(key: _fcmToken, value: token);
  }

  static Future<String?> getFCMToken() async {
    return await _storage.read(key: _fcmToken);
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
