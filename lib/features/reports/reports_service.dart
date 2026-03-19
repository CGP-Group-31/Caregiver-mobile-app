import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'report_model.dart';

class ReportsService {
  Future<List<CareReport>> fetchReports ({
    required int elderId,
    String? type,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try{
      final Response res = await DioClient.dio.get(
        "/api/v1/caregiver/care-reports/$elderId",
        queryParameters: {
          if (type != null && type.isNotEmpty) "type": type,
          if (search != null && search.trim().isNotEmpty) "search": search.trim(),
          "limit": limit,
          "offset": offset,
        },
      );

      final data = Map<String, dynamic>.from(res.data);
      final reports = (data["reports"] as List<dynamic>? ?? [])
          .map((e) => CareReport.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return reports;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? "Failed to load reports",
      );
    }
  }

  Future<CareReport> fetchReportDetail ({
    required int elderId,
    required int reportId,
  }) async {
    try {
      final Response res = await DioClient.dio.get(
        "/api/v1/caregiver/care-reports/$elderId/$reportId",
      );

      return CareReport.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            "Failed to load report detail",
      );
    }
  }
}