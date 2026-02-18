import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MedicineService {
  static Future<void> createMedicine({
    required int elderId,
    required int caregiverId,
    required String name,
    required String dosage, // ✅ STRING (backend expects string)
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
          "dosage": dosage, // ✅ send as string
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
          final error = responseData["detail"][0];
          final field = error["loc"][1];
          final message = error["msg"];
          throw Exception("$field|$message");
        } else {
          throw Exception("unknown|${responseData["detail"]}");
        }
      } else {
        throw Exception("unknown|Failed to create medicine");
      }
    }
  }
}
