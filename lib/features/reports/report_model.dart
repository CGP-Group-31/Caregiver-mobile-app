class CareReport {
  final int reportId;
  final int elderId;
  final String reportType;
  final String title;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String reportText;

  final ElderDayOverview? elderDayOverview;
  final List<String> painAreas;
  final List<String> activities;
  final String? aiCheckinInsights;
  final MedicationAdherenceSection medicationAdherence;
  final MealAdherenceSection mealAdherence;
  final List<String> concerns;
  final String? caregiverRecommendation;

  CareReport({
    required this.reportId,
    required this.elderId,
    required this.reportType,
    required this.title,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.reportText,
    this.elderDayOverview,
    this.painAreas = const [],
    this.activities = const [],
    this.aiCheckinInsights,
    required this.medicationAdherence,
    required this.mealAdherence,
    this.concerns = const [],
    this.caregiverRecommendation,
  });

  factory CareReport.fromJson(Map<String, dynamic> json) {
    final painReport = json["pain_report"] as Map<String, dynamic>?;

    return CareReport(
      reportId: json["report_id"] as int,
      elderId: json["elder_id"] as int,
      reportType: json["report_type"].toString(),
      title: (json["title"] ?? "Care Report").toString(),
      periodStart: DateTime.parse(json["period_start"].toString()),
      periodEnd: DateTime.parse(json["period_end"].toString()),
      generatedAt: DateTime.parse(json["generated_at"].toString()),
      reportText: (json["report_text"] ?? "").toString(),

      elderDayOverview: json["elder_day_overview"] != null
          ? ElderDayOverview.fromJson(
        Map<String, dynamic>.from(json["elder_day_overview"]),
      )
          : null,

      painAreas: (painReport?["pain_areas"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      activities: (json["activities"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      aiCheckinInsights: json["ai_checkin_insights"]?.toString(),

      medicationAdherence: json["medication_adherence"] != null
          ? MedicationAdherenceSection.fromJson(
        Map<String, dynamic>.from(json["medication_adherence"]),
      )
          : MedicationAdherenceSection.empty(),

      mealAdherence: json["meal_adherence"] != null
          ? MealAdherenceSection.fromJson(
        Map<String, dynamic>.from(json["meal_adherence"]),
      )
          : MealAdherenceSection.empty(),

      concerns: (json["concerns"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      caregiverRecommendation:
      json["caregiver_recommendation"]?.toString(),
    );
  }
}

class ElderDayOverview {
  final String? mood;
  final String? sleepQuantity;
  final String? waterIntake;
  final String? appetiteLevel;
  final String? energyLevel;
  final String? overallDay;
  final String? movementToday;
  final String? lonelinessLevel;
  final String? talkInteraction;
  final String? stressLevel;

  ElderDayOverview({
    this.mood,
    this.sleepQuantity,
    this.waterIntake,
    this.appetiteLevel,
    this.energyLevel,
    this.overallDay,
    this.movementToday,
    this.lonelinessLevel,
    this.talkInteraction,
    this.stressLevel,
  });

  factory ElderDayOverview.fromJson(Map<String, dynamic> json) {
    return ElderDayOverview(
      mood: json["mood"]?.toString(),
      sleepQuantity: json["sleep_quantity"]?.toString(),
      waterIntake: json["water_intake"]?.toString(),
      appetiteLevel: json["appetite_level"]?.toString(),
      energyLevel: json["energy_level"]?.toString(),
      overallDay: json["overall_day"]?.toString(),
      movementToday: json["movement_today"]?.toString(),
      lonelinessLevel: json["loneliness_level"]?.toString(),
      talkInteraction: json["talk_interaction"]?.toString(),
      stressLevel: json["stress_level"]?.toString(),
    );
  }
}

class MedicationAdherenceSection {
  final int takenCount;
  final int missedCount;
  final List<String> missedItems;

  MedicationAdherenceSection({
    required this.takenCount,
    required this.missedCount,
    required this.missedItems,
  });

  factory MedicationAdherenceSection.fromJson(Map<String, dynamic> json) {
    return MedicationAdherenceSection(
      takenCount: json["taken_count"] ?? 0,
      missedCount: json["missed_count"] ?? 0,
      missedItems: (json["missed_items"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  factory MedicationAdherenceSection.empty() {
    return MedicationAdherenceSection(
      takenCount: 0,
      missedCount: 0,
      missedItems: const [],
    );
  }
}

class MealAdherenceSection {
  final String? breakfast;
  final String? lunch;
  final String? dinner;

  MealAdherenceSection({
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  factory MealAdherenceSection.fromJson(Map<String, dynamic> json) {
    return MealAdherenceSection(
      breakfast: json["breakfast"]?.toString(),
      lunch: json["lunch"]?.toString(),
      dinner: json["dinner"]?.toString(),
    );
  }

  factory MealAdherenceSection.empty() {
    return MealAdherenceSection();
  }
}