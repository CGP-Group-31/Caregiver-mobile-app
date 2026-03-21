import 'package:firebase_messaging/firebase_messaging.dart';
import '../session/session_manager.dart';

class FCMManager {
  /// Call this at app start (or before login/register)
  static Future<String?> initAndGetToken() async {
    final messaging = FirebaseMessaging.instance;

    // Android 13+ permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get token
    final token = await messaging.getToken();
    if (token != null) {
      await SessionManager.saveFCMToken(token);
    }

    // Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await SessionManager.saveFCMToken(newToken);


    });

    return token;
  }
}