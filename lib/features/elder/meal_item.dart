class MealItem {
  final int id;
  final String mealTime;
  final DateTime scheduledFor;
  final String statusName;
  final String? diet;

  MealItem({
    required this.id,
    required this.mealTime,
    required this.scheduledFor,
    required this.statusName,
    this.diet,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['MealAdherenceID'],
      mealTime: json['MealTime'],
      scheduledFor: DateTime.parse(json['ScheduledFor']),
      statusName: json['StatusName'],
      diet: json['Diet'],
    );
  }
}