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
}