import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AppointmentService {

  static Future<void> createAppointment({
    required int elderId,
    required String doctorName,
    required String title,
    required String location,
    String? notes,
    required String appointmentDate,
    required String appointmentTime,
  }) async {

    try {
      await DioClient.dio.post(
        "/api/v1/caregiver/appointments/",
        data: {
          "elder_id": elderId,
          "doctor_name": doctorName,
          "title": title,
          "location": location,
          "notes": notes,
          "appointment_date": appointmentDate,
          "appointment_time": appointmentTime
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to create appointment");
    }
  }

  static Future<List> getAppointments(int elderId) async {

    try {
      final res = await DioClient.dio.get(
        "/api/v1/caregiver/appointments/elder/$elderId/upcoming-7-days",
      );

      return res.data;

    } on DioException catch (e) {

      if (e.response?.statusCode == 404) {
        return [];
      }

      throw Exception(e.response?.data ?? "Failed to load appointments");
    }
  }

  static Future<void> deleteAppointment(int appointmentId) async {

    try {
      await DioClient.dio.delete(
        "/api/v1/caregiver/appointments/$appointmentId",
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to delete appointment");
    }
  }
}