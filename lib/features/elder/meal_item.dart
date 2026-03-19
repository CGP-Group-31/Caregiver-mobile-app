enum MealStatus { missed, pending, taken }

class MealItem {
  final int mealAdherenceId;
  final int elderId;
  final String mealTime;
  final String scheduledFor;
  final MealStatus status;
  final String? diet;
  final String? updatedAt;

  MealItem({
    required this.mealAdherenceId,
    required this.elderId,
    required this.mealTime,
    required this.scheduledFor,
    required this.status,
    this.diet,
    this.updatedAt,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      mealAdherenceId: json['MealAdherenceID'] ?? 0,
      elderId: json['ElderID'] ?? 0,
      mealTime: (json['MealTime'] ?? '').toString(),
      scheduledFor: (json['ScheduledFor'] ?? '').toString(),
      status: _parseMealStatus((json['Status'] ?? '').toString()),
      diet: json['Diet']?.toString(),
      updatedAt: json['UpdatedAt']?.toString(),
    );
  }

  static MealStatus _parseMealStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case 'TAKEN':
        return MealStatus.taken;
      case 'MISSED':
        return MealStatus.missed;
      case 'PENDING':
      default:
        return MealStatus.pending;
    }
  }
}