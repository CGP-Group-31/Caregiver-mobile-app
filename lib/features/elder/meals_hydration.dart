import 'package:flutter/material.dart';
import 'package:caregiver/core/session/session_manager.dart';

import '../auth/theme.dart';
import 'meals_service.dart';
import 'meal_item.dart';

class MealsHydrationScreen extends StatefulWidget {
  const MealsHydrationScreen({super.key});

  @override
  State<MealsHydrationScreen> createState() => _MealsHydrationScreenState();
}

class _MealsHydrationScreenState extends State<MealsHydrationScreen> {
  final MealsService _service = MealsService();

  List<MealItem> meals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  Future<void> loadMeals() async {
    setState(() {
      loading = true;
      meals = [];
    });

    try {
      final elderId = await SessionManager.getElderId();

      if (elderId == null) return;

      final data = await _service.getTodayMeals(elderId);

      setState(() {
        meals = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget summaryCard() {
    int taken = meals.where((m) => m.statusName == "Taken").length;
    int total = meals.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        "$taken / $total Meals Completed",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget mealItem(MealItem meal) {
    final style = _getStatusStyle(meal.statusName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        /// Meal name
        title: Text(
          meal.mealTime,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),

        /// Details
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            Text(
              "Time: ${_formatTime(meal.scheduledFor)}",
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: AppColors.descriptionText,
              ),
            ),

            if (meal.diet != null && meal.diet!.isNotEmpty)
              Text(
                "Diet: ${meal.diet}",
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppColors.descriptionText,
                ),
              ),
          ],
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: style.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            meal.statusName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: style.fg,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Today's Meals",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!loading && meals.isNotEmpty) summaryCard(),

            const Text(
              "Today Status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : meals.isEmpty
                  ? const Center(
                child: Text(
                  "No meals found",
                  style: TextStyle(fontSize: 14),
                ),
              )
                  : RefreshIndicator(
                onRefresh: loadMeals,
                child: ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return mealItem(meals[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatusStyle {
  final Color bg;
  final Color fg;

  _StatusStyle(this.bg, this.fg);
}

_StatusStyle _getStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case "taken":
      return _StatusStyle(
        AppColors.primary.withOpacity(0.15),
        AppColors.primary,
      );

    case "pending":
      return _StatusStyle(
        AppColors.alertNonCritical.withOpacity(0.2),
        AppColors.alertNonCritical,
      );

    default:
      return _StatusStyle(
        AppColors.sectionSeparator.withOpacity(0.3),
        AppColors.primaryText,
      );
  }
}


String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}