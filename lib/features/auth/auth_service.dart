import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_manager.dart';

class AuthService {
  static final _dio = DioClient.dio;

  /// Helper: get device model
  static Future<String> _getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? "unknown";
  }

  /// REGISTER with dummy FCM & device info
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
      const fcmToken = "dummy_fcm_token";
      const appType = "android";

      final deviceModel = await _getDeviceModel();

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
          "fcm_token": fcmToken,
          "app_type": appType,
          "device_model": deviceModel,
        },
      );

      await SessionManager.saveFCMToken(fcmToken);

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
      const fcmToken = "dummy_fcm_token";
      const appType = "android";

      final deviceModel = await _getDeviceModel();

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

      await SessionManager.saveFCMToken(fcmToken);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Login failed");
    }
  }
}
