import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  static const _userId = "user_id"; // caregiver id
  static const _elderId = "elder_id";
  static const _relationshipId = "relationship_id";
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

  static Future<void> saveElderData(int elderId, int relationshipId) async {
    await _storage.write(key: _elderId, value: elderId.toString());
    await _storage.write(
        key: _relationshipId, value: relationshipId.toString());
  }

  static Future<int?> getElderId() async {
    final value = await _storage.read(key: _elderId);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _loggedIn);
    return value == "true";
  }

  static Future<void> saveFCMToken(String token) async {
    await _storage.write(key: _fcmToken, value: token);
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
