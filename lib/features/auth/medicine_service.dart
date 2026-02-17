import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MedicineService {
  static Future<void> createMedicine({
    required int elderId,
    required int caregiverId,
    required String name,
    required String dosage,
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
          "dosage": dosage.toString(),        // FORCE STRING
          "instructions": instructions,
          "time": time.toString(),            // FORCE STRING
          "repeatDays": repeatDays.toString(),// FORCE STRING
          "startDate": startDate,
          "endDate": endDate,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["detail"] ?? "Failed to create medicine",
      );
    }
  }
}
