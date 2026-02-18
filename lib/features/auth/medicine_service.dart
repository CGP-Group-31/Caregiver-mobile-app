import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MedicineService {
  static Future<void> createMedicine({
    required int elderId,
    required int caregiverId,
    required String name,
    required int dosage,
    required String instructions,
    required String time,
    required String repeatDays,
    required String startDate,
    required String endDate,
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
          "time": time,
          "repeatDays": repeatDays,
          "startDate": startDate,
          "endDate": endDate,
        },
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData != null && responseData["detail"] != null) {
        if (responseData["detail"] is List) {
          throw Exception(responseData["detail"][0]["msg"]);
        } else {
          throw Exception(responseData["detail"].toString());
        }
      } else {
        throw Exception("Failed to create medicine");
      }
    }
  }
}
