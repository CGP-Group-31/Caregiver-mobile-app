import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/session/session_manager.dart';

class AuthService {
  static final _dio = DioClient.dio;

  /// REGISTER
  static Future<int> registerCaregiver({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String dateOfBirth,
    required String gender,
    required String address,
  }) async {
    try {
      final response = await _dio.post(
        "/api/v1/caregiver/auth/register",
        data: {
          "full_name": fullName,
          "email": email,
          "phone": phone,
          "password": password,
          "date_of_birth": dateOfBirth,
          "gender": gender,
          "address": address,
        },
      );

      return response.data["user_id"];
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Registration failed");
    }
  }

  /// LOGIN with dummy FCM & device info
  static Future<Map<String, dynamic>> loginCaregiver({
    required String email,
    required String password,
  }) async {
    try {
      // Dummy values for now
      const fcmToken = "dummy_fcm_token";
      const appType = "android";

      // Get device model
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final deviceModel = androidInfo.model ?? "unknown";

      final response = await _dio.post(
        "/api/v1/caregiver/auth/login",
        data: {
          "email": email,
          "password": password,
          "fcm_token": fcmToken,
          "app_type": appType,
          "device_model": deviceModel,
        },
      );

      // Save FCM token in session
      await SessionManager.saveFCMToken(fcmToken);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Login failed");
    }
  }
}
