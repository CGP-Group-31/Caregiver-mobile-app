import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class DashboardService {
  Future<Map<String, dynamic>> fetchDashboardHome({
    required int elderId,
    required int caregiverId,
}) async {
    try {
      final Response res = await DioClient.dio.get(
        "/api/v1/caregiver/dashboard/elder/$elderId/home",
        queryParameters: {"caregiver_id": caregiverId},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message ?? "Failed to load dashboard");
    }
  }

  Future<int> fetchMissedMedicineCount(int elderId) async {
    final res = await DioClient.dio.get(
      "/api/v1/caregiver/dashboard/elder/$elderId/medication/missed-today-count",
    );
    return (res.data["missed_tdy_count"] ?? 0) as int;
  }

  Future<int> fetchUpcomingAppointmentsCount(int elderId) async {
    final res = await DioClient.dio.get(
      "/api/v1/caregiver/dashboard/elder/$elderId/appointments/upcoming-count",
    );
    return (res.data["upcoming_count"] ?? 0) as int;
  }

  Future<int> fetchTodayScheduleCount(int elderId) async {
    final res = await DioClient.dio.get(
      "/api/v1/caregiver/medicine/elder/$elderId/today-scheduled",
    );
    final list = (res.data as List<dynamic>? ?? []);
    return list.length;
  }

  Future<int> fetchTodayTakenCount(int elderId) async {
    final res = await DioClient.dio.get(
      "/api/v1/caregiver/medicine/elder/$elderId/today-taken",
    );
    final list = (res.data as List<dynamic>? ?? []);
    return list.length;
  }
}