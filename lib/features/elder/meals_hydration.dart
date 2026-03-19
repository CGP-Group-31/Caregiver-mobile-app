import 'package:flutter/material.dart';
import 'package:caregiver/core/session/session_manager.dart';

import '../auth/theme.dart';
import 'meal_item.dart';
import 'meals_service.dart';

class MealsHydrationScreen extends StatefulWidget {
  const MealsHydrationScreen({
    super.key,
    this.elderName,
    this.waterTakenMl = 750,
  });

  final String? elderName;
  final int waterTakenMl;

  @override
  State<MealsHydrationScreen> createState() => _MealsHydrationScreenState();
}

class _MealsHydrationScreenState extends State<MealsHydrationScreen> {
  final MealsService _service = MealsService();

  bool _loading = true;
  String? _error;
  bool _noMealsToday = false;

  MealStatus _breakfastStatus = MealStatus.pending;
  MealStatus _lunchStatus = MealStatus.pending;
  MealStatus _dinnerStatus = MealStatus.pending;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
        _noMealsToday = false;
      });

      final elderId = await SessionManager.getElderId();

      if (elderId == null) {
        if (!mounted) return;
        setState(() {
          _error = "Elder ID not found in session.";
          _loading = false;
        });
        return;
      }

      final meals = await _service.getTodayMeals(elderId);

      if (meals.isEmpty) {
        if (!mounted) return;
        setState(() {
          _breakfastStatus = MealStatus.pending;
          _lunchStatus = MealStatus.pending;
          _dinnerStatus = MealStatus.pending;
          _noMealsToday = true;
          _loading = false;
        });
        return;
      }

      MealStatus breakfast = MealStatus.pending;
      MealStatus lunch = MealStatus.pending;
      MealStatus dinner = MealStatus.pending;

      for (final meal in meals) {
        final mealName = meal.mealTime.toUpperCase().trim();

        if (mealName == "BREAKFAST") {
          breakfast = meal.status;
        } else if (mealName == "LUNCH") {
          lunch = meal.status;
        } else if (mealName == "DINNER") {
          dinner = meal.status;
        }
      }

      if (!mounted) return;

      setState(() {
        _breakfastStatus = breakfast;
        _lunchStatus = lunch;
        _dinnerStatus = dinner;
        _noMealsToday = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshMeals() async {
    await _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.mainBackground,
        foregroundColor: AppColors.primaryText,
        title: const Text(
          "Meals And Hydration",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _loading ? null : _refreshMeals,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const _SoftBackgroundShapes(),
            RefreshIndicator(
              onRefresh: _refreshMeals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.elderName != null) ...[
                      _ChipLabel(text: "For ${widget.elderName}"),
                      const SizedBox(height: 12),
                    ],
                    _MainCard(
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _error != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Meals",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.emergencyBackground
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.sosButton
                                              .withOpacity(0.35),
                                        ),
                                      ),
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _refreshMeals,
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text("Try Again"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : _noMealsToday
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Meals",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.sectionBackground
                                                .withOpacity(0.35),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color:
                                                  AppColors.sectionSeparator,
                                            ),
                                          ),
                                          child: const Text(
                                            "No meals scheduled for today.",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        const _StrongDivider(),
                                        const SizedBox(height: 18),
                                        const Text(
                                          "Hydration",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _InfoTile(
                                          icon: Icons.water_drop_rounded,
                                          title: "Water Taken Today",
                                          value: "${widget.waterTakenMl} ml",
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "This page is read-only. It updates when the elder responds to reminders.",
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            height: 1.25,
                                            color:
                                                AppColors.descriptionText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Meals",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _MealRow(
                                          mealName: "Breakfast",
                                          status: _breakfastStatus,
                                        ),
                                        const _SoftDivider(),
                                        _MealRow(
                                          mealName: "Lunch",
                                          status: _lunchStatus,
                                        ),
                                        const _SoftDivider(),
                                        _MealRow(
                                          mealName: "Dinner",
                                          status: _dinnerStatus,
                                        ),
                                        const SizedBox(height: 18),
                                        const _StrongDivider(),
                                        const SizedBox(height: 18),
                                        const Text(
                                          "Hydration",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _InfoTile(
                                          icon: Icons.water_drop_rounded,
                                          title: "Water Taken Today",
                                          value: "${widget.waterTakenMl} ml",
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "This page is read-only. It updates when the elder responds to reminders.",
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            height: 1.25,
                                            color:
                                                AppColors.descriptionText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  const _MainCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sectionSeparator),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.containerBackground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.sectionSeparator),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.mealName,
    required this.status,
  });

  final String mealName;
  final MealStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mealName,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
          _StatusBadge(status: status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MealStatus status;

  @override
  Widget build(BuildContext context) {
    final _StatusStyle style = _style(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 18, color: style.fg),
          const SizedBox(width: 8),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: style.fg,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _style(MealStatus status) {
    switch (status) {
      case MealStatus.taken:
        return _StatusStyle(
          label: "TAKEN",
          icon: Icons.check_circle_rounded,
          fg: AppColors.primary,
          bg: AppColors.sectionBackground.withOpacity(0.55),
          border: AppColors.sectionSeparator,
        );
      case MealStatus.pending:
        return _StatusStyle(
          label: "PENDING",
          icon: Icons.hourglass_top_rounded,
          fg: AppColors.primaryText,
          bg: AppColors.alertNonCritical.withOpacity(0.25),
          border: AppColors.alertNonCritical.withOpacity(0.55),
        );
      case MealStatus.missed:
        return _StatusStyle(
          label: "MISSED",
          icon: Icons.error_rounded,
          fg: AppColors.sosButton,
          bg: AppColors.emergencyBackground.withOpacity(0.75),
          border: AppColors.sosButton.withOpacity(0.55),
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final Color border;

  _StatusStyle({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.border,
  });
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sectionSeparator),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.sectionSeparator.withOpacity(0.9),
    );
  }
}

class _StrongDivider extends StatelessWidget {
  const _StrongDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.3,
      color: AppColors.textShade.withOpacity(0.25),
    );
  }
}

class _SoftBackgroundShapes extends StatelessWidget {
  const _SoftBackgroundShapes();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.sectionBackground.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -110,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.sectionSeparator.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}