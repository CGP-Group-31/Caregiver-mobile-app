import 'package:caregiver/core/network/dio_client.dart';
import 'package:caregiver/core/session/session_manager.dart';
import 'package:caregiver/features/elder/elder_model.dart';
import 'package:dio/dio.dart';

class ElderService {
  /// GET Elder Details
  static Future<ElderModel> getElderDetails() async {
    final elderId = await SessionManager.getElderId();
    if (elderId == null || elderId == 0) throw Exception("Invalid elder id in session");

    try {
      final response = await DioClient.dio.get('/api/v1/caregiver/elder/$elderId');
      
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
      
      // THE FIX: If the server response is missing the ID, inject the one we just used
      if (data['id'] == null && data['elder_id'] == null && data['user_id'] == null && data['UserID'] == null) {
        data['id'] = elderId;
      }
      
      return ElderModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception("Failed to load elder: ${e.response?.statusCode}");
    }
  }

  /// PATCH Elder Details - Force use of valid ID
  static Future<void> patchElderDetails({
    required int elderId, 
    required Map<String, dynamic> data,
  }) async {
    // If model has ID 0, try to get the real one from session
    int? finalId = (elderId == 0) ? await SessionManager.getElderId() : elderId;

    if (finalId == null || finalId == 0) {
      throw Exception("Update aborted: ID is invalid ($finalId)");
    }

    try {
      await DioClient.dio.patch('/api/v1/caregiver/elder/$finalId', data: data);
    } on DioException catch (e) {
      throw Exception("Update failed: ${e.response?.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> getMedicalProfile() async {
    final elderId = await SessionManager.getElderId();
    if (elderId == null || elderId == 0) throw Exception('Elder ID not found.');
    try {
      final response = await DioClient.dio.get('/api/v1/caregiver/elder/medical-profile/$elderId');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to load medical profile: ${e.response?.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getPreferredDoctor() async {
    final elderId = await SessionManager.getElderId();
    if (elderId == null || elderId == 0) throw Exception('Elder ID not found.');
    try {
      final response = await DioClient.dio.get('/api/v1/caregiver/elder/preferred-doctor/$elderId');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return {};
      throw Exception('Failed to load preferred doctor: ${e.response?.statusCode}');
    }
  }

  static Future<void> updatePreferredDoctor({
    required int elderId,
    required int doctorId,
  }) async {
    try {
      await DioClient.dio.patch(
        '/api/v1/caregiver/elder/preferred-doctor/$elderId',
        data: {"PreferredDoctorID": doctorId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await DioClient.dio.patch('/api/v1/caregiver/elder/$elderId', data: {"preferred_doctor_id": doctorId});
      } else {
        throw Exception('Failed to update doctor: ${e.response?.statusCode}');
      }
    }
  }

  static Future<List<dynamic>> searchDoctors({String? name, String? hospital}) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/caregiver/elder-create/search-doctors',
        data: {"doctor_name": name ?? "", "hospital": hospital ?? ""},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to search doctors: ${e.response?.statusCode}');
    }
  }
}
