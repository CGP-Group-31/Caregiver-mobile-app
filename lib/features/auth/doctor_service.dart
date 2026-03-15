import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class DoctorService {
  static final Dio _dio = DioClient.dio;

  static Future<List<DoctorItem>> searchDoctors({
    required String doctorName,
    String hospital = "",
  }) async {
    final name = doctorName.trim();
    final hosp = hospital.trim();

    // If both are empty, don't call the API
    if (name.isEmpty && hosp.isEmpty) return [];

    try {
      final response = await _dio.post(
        "/api/v1/caregiver/elder-create/search-doctors",
        data: {
          "doctor_name": name,
          "hospital": hosp,
        },
        options: Options(
          validateStatus: (code) =>
          code != null && ((code >= 200 && code < 300) || code == 404),
        ),
      );

      if (response.statusCode == 404) return [];

      final data = response.data;

      if (data is! List) return [];

      return data
          .map((e) => DoctorItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];

      throw Exception(e.response?.data ?? "Doctor search failed");
    }
  }
}

class DoctorItem {
  final int doctorId;
  final String fullName;
  final String specialization;
  final String hospital;

  DoctorItem({
    required this.doctorId,
    required this.fullName,
    required this.specialization,
    required this.hospital,
  });

  factory DoctorItem.fromJson(Map<String, dynamic> json) {
    return DoctorItem(
      doctorId: (json["doctor_id"] ?? 0) as int,
      fullName: (json["full_name"] ?? "") as String,
      specialization: (json["specialization"] ?? "") as String,
      hospital: (json["hospital"] ?? "") as String,
    );
  }
}