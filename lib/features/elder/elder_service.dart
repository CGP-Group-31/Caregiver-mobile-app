import 'package:caregiver/core/network/dio_client.dart';
import 'package:caregiver/core/session/session_manager.dart';
import 'package:caregiver/features/elder/elder_model.dart';
import 'package:dio/dio.dart';

class ElderService {
  static Future<ElderModel> getElderDetails() async {
    final elderId = await SessionManager.getElderId();
    if (elderId == null) throw Exception('Elder ID not found.');

    try {
      final response = await DioClient.dio.get('/api/v1/caregiver/elder/$elderId');
      return ElderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load elder: ${e.response?.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getMedicalProfile() async {
    final elderId = await SessionManager.getElderId();
    if (elderId == null) throw Exception('Elder ID not found.');

    try {
      final response = await DioClient.dio.get('/api/v1/caregiver/elder/medical-profile/$elderId');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to load medical profile: ${e.response?.statusCode}');
    }
  }

  static Future<void> patchElderDetails({
    required int elderId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Try plural first
      await DioClient.dio.patch('/api/v1/caregiver/elders/$elderId', data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback to singular
        await DioClient.dio.patch('/api/v1/caregiver/elder/$elderId', data: data);
      } else {
        throw Exception('Failed to update elder: ${e.response?.statusCode}');
      }
    }
  }
}
