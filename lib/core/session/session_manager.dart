import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  SessionManager._();

  /// Stronger Android secure storage (EncryptedSharedPreferences)
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  // Keys
  static const String _kUserId = "user_id"; // caregiver id
  static const String _kElderId = "elder_id";
  static const String _kRelationshipId = "relationship_id";
  static const String _kLoggedIn = "logged_in";
  static const String _kFcmToken = "fcm_token";

  // Optional (helps later)
  static const String _kRole = "role";         // caregiver
  static const String _kEmail = "email";
  static const String _kAppType = "app_type";  //  caregiver


  // Basic Auth Session
  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: _kLoggedIn, value: value ? "true" : "false");
  }

  static Future<bool> isLoggedIn() async {
    final v = await _storage.read(key: _kLoggedIn);
    return v == "true";
  }

  static Future<void> saveUser(int userId) async {
    await _storage.write(key: _kUserId, value: userId.toString());
    await setLoggedIn(true);
  }

  static Future<int?> getUserId() async {
    final v = await _storage.read(key: _kUserId);
    return int.tryParse(v ?? "");
  }

  // Optional meta
  static Future<void> saveRole(String role) async {
    await _storage.write(key: _kRole, value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _kRole);
  }

  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _kEmail, value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _kEmail);
  }

  static Future<void> saveAppType(String appType) async {
    await _storage.write(key: _kAppType, value: appType);
  }

  static Future<String?> getAppType() async {
    return await _storage.read(key: _kAppType);
  }

  // Elder / Relationship

  static Future<void> saveElderData(int elderId, int relationshipId) async {
    await _storage.write(key: _kElderId, value: elderId.toString());
    await _storage.write(key: _kRelationshipId, value: relationshipId.toString());
  }

  static Future<int?> getElderId() async {
    final v = await _storage.read(key: _kElderId);
    return int.tryParse(v ?? "");
  }

  static Future<int?> getRelationshipId() async {
    final v = await _storage.read(key: _kRelationshipId);
    return int.tryParse(v ?? "");
  }

  // FCM Token

  static Future<void> saveFCMToken(String token) async {
    // Avoid saving empty token
    if (token.trim().isEmpty) return;
    await _storage.write(key: _kFcmToken, value: token.trim());
  }

  static Future<String?> getFCMToken() async {
    return await _storage.read(key: _kFcmToken);
  }

  static Future<void> clearFCMToken() async {
    await _storage.delete(key: _kFcmToken);
  }
  // Utilities

  /// Clears only elder mapping (keep login/user)
  static Future<void> clearElderData() async {
    await _storage.delete(key: _kElderId);
    await _storage.delete(key: _kRelationshipId);
  }

  /// Full logout (clears everything)
  static Future<void> logout() async {
    await _storage.deleteAll(aOptions: _androidOptions);
  }

  /// Debug helper (don’t use in production logs)
  static Future<Map<String, String>> dumpAll() async {
    return await _storage.readAll(aOptions: _androidOptions);
  }


  static Future<Map<String, String?>> dumpKnownSessionKeys() async {
    final userId = await _storage.read(key: _kUserId, aOptions: _androidOptions);
    final elderId = await _storage.read(key: _kElderId, aOptions: _androidOptions);
    final relationshipId = await _storage.read(key: _kRelationshipId, aOptions: _androidOptions);
    final loggedIn = await _storage.read(key: _kLoggedIn, aOptions: _androidOptions);
    final fcmToken = await _storage.read(key: _kFcmToken, aOptions: _androidOptions);
    final role = await _storage.read(key: _kRole, aOptions: _androidOptions);
    final email = await _storage.read(key: _kEmail, aOptions: _androidOptions);
    final appType = await _storage.read(key: _kAppType, aOptions: _androidOptions);

    return {
      _kUserId: userId,
      _kElderId: elderId,
      _kRelationshipId: relationshipId,
      _kLoggedIn: loggedIn,
      _kFcmToken: fcmToken,
      _kRole: role,
      _kEmail: email,
      _kAppType: appType,
    };
  }
  /// Debug: Pretty print session values (shows nulls too)
  static Future<void> debugPrintSession({String tag = "SESSION"}) async {
    final map = await dumpKnownSessionKeys();
    for (final e in map.entries) {
      print("${e.key}: ${e.value ?? "null"}");
    }
  }
}