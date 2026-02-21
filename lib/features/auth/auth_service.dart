import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';
import 'contact_model.dart'; // Import the contact model

class AuthService {
  static final Dio _dio = DioClient.dio;

  // ================= DEVICE MODEL =================
  static Future<String> _getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? "unknown";
  }

  // ================= ERROR HANDLER (RESTORED) =================
  static Exception _handleError(DioException e) {
    final responseData = e.response?.data;

    if (responseData != null && responseData["detail"] != null) {
      if (responseData["detail"] is List) {
        final error = responseData["detail"][0];
        final message = error["msg"];
        if (error["loc"] is List && error["loc"].length > 1) {
          final field = error["loc"][1];
          return Exception('$field: $message');
        }
        return Exception(message);
      } else {
        return Exception(responseData["detail"].toString());
      }
    }

    return Exception("Request failed");
  }

  // ================= REGISTER =================
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
      throw _handleError(e);
    }
  }

  // ================= LOGIN =================
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
      throw _handleError(e);
    }
  }

  // ================= CREATE ELDER =================
  static Future<Map<String, dynamic>> createElder({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String dateOfBirth,
    required String gender,
    required String address,
    required int caregiverId,
    required String relationshipType,
    required bool isPrimary,
  }) async {
    try {
      final response = await _dio.post(
        "/api/v1/caregiver/elder-create/register",
        data: {
          "full_name": fullName,
          "email": email,
          "phone": phone,
          "password": password,
          "date_of_birth": dateOfBirth,
          "gender": gender,
          "address": address,
          "caregiver_id": caregiverId,
          "relationship_type": relationshipType,
          "is_primary": isPrimary,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ================= EMERGENCY CONTACTS (RESTORED) =================

  static Future<void> createEmergencyContact({
    required int elderId,
    required String name,
    required String phone,
    required String relation,
  }) async {
    try {
      await _dio.post(
        "/api/v1/caregiver/elder-create/emergency-contacts",
        data: {
          "elder_id": elderId,
          "contact_name": name,
          "phone": phone,
          "relationship": relation,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<ContactModel>> getEmergencyContacts(int elderId) async {
    try {
      final response = await _dio.get(
        "/api/v1/caregiver/elder-create/get-emergency-contacts/$elderId",
      );
      final List<dynamic> data = response.data;
      return data.map((json) => ContactModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
