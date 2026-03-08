import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';

class CaregiverViewLocation extends StatefulWidget {
  const CaregiverViewLocation({super.key});

  @override
  State<CaregiverViewLocation> createState() => _CaregiverViewLocationState();
}

class _CaregiverViewLocationState extends State<CaregiverViewLocation> {
  final Dio _dio = DioClient.dio;

  bool _loading = false;
  bool _loadedSuccessfully = false;
  bool _loadFailed = false;

  String _status = "Loading latest location...";
  String _latitude = "--";
  String _longitude = "--";
  String _sharedTime = "--";

  final List<Map<String, String>> _locationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadLatestLocation();
  }

  Future<void> _loadLatestLocation() async {
    setState(() {
      _loading = true;
      _loadedSuccessfully = false;
      _loadFailed = false;
      _status = "Loading latest location...";
      _latitude = "--";
      _longitude = "--";
      _sharedTime = "--";
      _locationHistory.clear();
    });

    try {
      final elderId = await SessionManager.getElderId();
      if (elderId == null) {
        throw Exception("Elder ID not found.");
      }

      Map<String, dynamic> latestLocation = {};
      List<Map<String, dynamic>> historyList = [];

      // latest
      try {
        final latestResponse = await _dio.get(
          "/api/v1/caregiver/location-sharing/elder/$elderId/latest",
        );

        final latestRes = latestResponse.data;
        latestLocation = (latestRes is Map && latestRes["location"] is Map)
            ? Map<String, dynamic>.from(latestRes["location"])
            : <String, dynamic>{};
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _loadedSuccessfully = false;
            _loadFailed = false;
            _status = "No latest location found";
            _latitude = "--";
            _longitude = "--";
            _sharedTime = "--";
            _locationHistory.clear();
          });
          return;
        }
        rethrow;
      }

      // history
      try {
        final historyResponse = await _dio.get(
          "/api/v1/caregiver/location-sharing/elder/$elderId/history",
        );

        final historyRes = historyResponse.data;
        historyList = (historyRes is Map && historyRes["history"] is List)
            ? List<Map<String, dynamic>>.from(
                (historyRes["history"] as List).map(
                  (e) => Map<String, dynamic>.from(e),
                ),
              )
            : <Map<String, dynamic>>[];
      } on DioException catch (e) {
        // history not found should NOT fail the whole page
        if (e.response?.statusCode != 404) {
          rethrow;
        }
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadedSuccessfully = true;
        _loadFailed = false;
        _status = historyList.isEmpty
            ? "Latest location loaded"
            : "Latest location loaded";

        _latitude = (latestLocation["Latitude"] ?? "--").toString();
        _longitude = (latestLocation["Longitude"] ?? "--").toString();
        _sharedTime = _formatRecordedAt(
          latestLocation["RecordedAt"] ?? latestLocation["RecordedBy"],
        );

        _locationHistory
          ..clear()
          ..addAll(
            historyList.map(
              (item) => {
                "latitude": (item["Latitude"] ?? "--").toString(),
                "longitude": (item["Longitude"] ?? "--").toString(),
                "time": _formatRecordedAt(
                  item["RecordedAt"] ?? item["RecordedBy"],
                ),
              },
            ),
          );
      });
    } on DioException catch (e) {
      if (!mounted) return;

      String message = "Failed to load latest location";
      final responseData = e.response?.data;

      if (responseData is Map && responseData["detail"] != null) {
        message = responseData["detail"].toString();
      }

      setState(() {
        _loading = false;
        _loadedSuccessfully = false;
        _loadFailed = true;
        _status = message;
        _latitude = "--";
        _longitude = "--";
        _sharedTime = "--";
        _locationHistory.clear();
      });
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst("Exception: ", "");

      setState(() {
        _loading = false;
        _loadedSuccessfully = false;
        _loadFailed = true;
        _status = message.isEmpty ? "Failed to load latest location" : message;
        _latitude = "--";
        _longitude = "--";
        _sharedTime = "--";
        _locationHistory.clear();
      });
    }
  }

  String _formatRecordedAt(dynamic value) {
    if (value == null) return "--";

    try {
      final dt = DateTime.parse(value.toString()).toLocal();

      final year = dt.year.toString().padLeft(4, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');

      int hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final suffix = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$year-$month-$day  $hour:$minute $suffix";
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> _openMaps() async {
    if (!_loadedSuccessfully || _latitude == "--" || _longitude == "--") return;

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude",
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _loadFailed
        ? const Color(0xFFB00020)
        : _loading
            ? const Color(0xFF2E7D7A)
            : const Color(0xFF243333);

    final Color borderColor =
        _loadFailed ? const Color(0xFFE7B8B8) : const Color(0xFFBEE8DA);

    final IconData headerIcon = _loadFailed
        ? Icons.error_outline_rounded
        : _loading
            ? Icons.gps_fixed_rounded
            : Icons.location_on_rounded;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Elder Location"),
        backgroundColor: const Color(0xFF2E7D7A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFD6EFE6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          headerIcon,
                          color: const Color(0xFF2E7D7A),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Latest Location Details",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF243333),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEE8DA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Latitude",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6F7F7D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _latitude,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF243333),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Longitude",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6F7F7D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _longitude,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF243333),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Shared Time",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6F7F7D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sharedTime,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF243333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBEE8DA),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: Color(0xFF2E7D7A),
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Location History",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF243333),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_locationHistory.isEmpty)
                      const Text(
                        "No location history available",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6F7F7D),
                        ),
                      )
                    else
                      ..._locationHistory.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5F1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Text(
                                          "LAT:",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF2E7D7A),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item["latitude"] ?? "--",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF243333),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Text(
                                          "LON:",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF2E7D7A),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item["longitude"] ?? "--",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF243333),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item["time"] ?? "--",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6F7F7D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _loadLatestLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D7A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _loading ? "Refreshing..." : "Refresh Location",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _loadedSuccessfully ? _openMaps : null,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text(
                    "Open in Maps",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D7A),
                    side: const BorderSide(
                      color: Color(0xFF2E7D7A),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}