import 'package:dio/dio.dart';

class AdditionalInfoService {

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://YOUR_BACKEND_URL", // change this
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static Future<void> submitInfo({
    required int elderId,
    required int caregiverId,
    required String cognitive,
    required String preferences,
    required String social,
    required String healthGoals,
    required String specialNotes,
  }) async {

    final now = DateTime.now();

    await dio.post(
      "/additional-info/",
      data: {
        "elder_id": elderId,
        "caregiver_id": caregiverId,
        "cognitive_behavior_notes": cognitive,
        "preferences": preferences,
        "social_emotional_behavior_notes": social,
        "health_goals": healthGoals,
        "special_notes_observations": specialNotes,
        "phone_date": now.toIso8601String().split("T")[0],
      },
    );
  }
}