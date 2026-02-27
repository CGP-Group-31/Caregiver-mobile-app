import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MedicineService {
  static Future<void> createMedicine({
    required int elderId,
    required int caregiverId,
    required String name,
    required String dosage,
    required String instructions,
    required List<String> times,      // ["08:00","20:00"]
    required String repeatDays,       // "Daily" | "EveryOtherDay" | "Mon,Wed,Fri"
    required String startDate,        // "yyyy-MM-dd"
    String? endDate,                  // "yyyy-MM-dd" or null
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
        // FastAPI validation errors (list format)
        if (responseData["detail"] is List) {
          final err = responseData["detail"][0];
          final loc = err["loc"];
          final field = (loc is List && loc.length > 1) ? loc[1] : "unknown";
          final msg = err["msg"] ?? "Validation error";
          throw Exception("$field|$msg");
        }

        // normal error string
        throw Exception("unknown|${responseData["detail"]}");
      }

      throw Exception("unknown|Failed to create medicine");
    }
  }
}