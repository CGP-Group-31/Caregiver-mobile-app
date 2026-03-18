import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MedicineService {

  /// CREATE MEDICINE

  static Future<void> createMedicine({
    required int elderId,
    required int caregiverId,
    required String name,
    required String dosage,
    required String instructions,
    required List<String> times,
    required String repeatDays,
    required String startDate,
    String? endDate,
  }) async {

    try {

      await DioClient.dio.post(
        "/api/v1/caregiver/medication/create",
        data: {
          "elderId": elderId,
          "caregiverId": caregiverId,
          "name": name,
          "dosage": dosage,
          "instructions": instructions,
          "times": times,
          "repeatDays": repeatDays,
          "startDate": startDate,
          "endDate": endDate,
        },
      );

    } on DioException catch (e) {

      final responseData = e.response?.data;

      if (responseData != null && responseData["detail"] != null) {

        if (responseData["detail"] is List) {
          final err = responseData["detail"][0];
          final loc = err["loc"];
          final field = (loc is List && loc.length > 1) ? loc[1] : "unknown";
          final msg = err["msg"] ?? "Validation error";

          throw Exception("$field|$msg");
        }

        throw Exception("unknown|${responseData["detail"]}");
      }

      throw Exception("unknown|Failed to create medicine");
    }
  }


  /// GET MEDICINE BY ID
  static Future<Map<String, dynamic>> getMedicineById(int medicineId) async {

    try {

      final response = await DioClient.dio.get(
        "/api/v1/caregiver/medication/$medicineId",
      );

      return response.data;

    } on DioException catch (e) {

      final responseData = e.response?.data;

      if (responseData != null && responseData["detail"] != null) {
        throw Exception(responseData["detail"]);
      }

      throw Exception("Failed to fetch medicine details");
    }
  }


  /// UPDATE MEDICINE
  static Future<void> updateMedicine({
    required int medicineId,
    required String name,
    required String dosage,
    required String instructions,
    required List<String> times,
    required String repeatDays,
    required String startDate,
    String? endDate,
  }) async {

    try {

      await DioClient.dio.put(
        "/api/v1/caregiver/medication/update/$medicineId",
        data: {
          "name": name,
          "dosage": dosage,
          "instructions": instructions,
          "times": times,
          "repeatDays": repeatDays,
          "startDate": startDate,
          "endDate": endDate,
        },
      );

    } on DioException catch (e) {

      final responseData = e.response?.data;

      if (responseData != null && responseData["detail"] != null) {

        if (responseData["detail"] is List) {
          final err = responseData["detail"][0];
          final loc = err["loc"];
          final field = (loc is List && loc.length > 1) ? loc[1] : "unknown";
          final msg = err["msg"] ?? "Validation error";

          throw Exception("$field|$msg");
        }

        throw Exception("unknown|${responseData["detail"]}");
      }

      throw Exception("unknown|Failed to update medicine");
    }
  }



  /// DELETE MEDICINE (SOFT DELETE)

  static Future<void> deleteMedicine(int medicineId) async {

    try {

      await DioClient.dio.delete(
        "/api/v1/caregiver/medication/delete/$medicineId",
      );

    } on DioException catch (e) {

      final responseData = e.response?.data;

      if (responseData != null && responseData["detail"] != null) {
        throw Exception(responseData["detail"]);
      }

      throw Exception("Failed to delete medicine");
    }
  }
}