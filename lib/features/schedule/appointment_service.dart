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
  }

  static Future<List> getAppointments(int elderId) async {

    final res = await DioClient.dio.get(
      "/api/v1/caregiver/appointments/elder/$elderId",
    );

    return res.data;
  }

  static Future<void> updateAppointment({
    required int appointmentId,
    String? doctorName,
    String? title,
    String? location,
    String? notes,
    String? appointmentDate,
    String? appointmentTime,
  }) async {

    await DioClient.dio.patch(
      "/api/v1/caregiver/appointments/$appointmentId",
      data: {
        "doctor_name": doctorName,
        "title": title,
        "location": location,
        "notes": notes,
        "appointment_date": appointmentDate,
        "appointment_time": appointmentTime
      },
    );
  }

  static Future<void> deleteAppointment(int appointmentId) async {

    await DioClient.dio.delete(
      "/api/v1/caregiver/appointments/$appointmentId",
    );
  }
}