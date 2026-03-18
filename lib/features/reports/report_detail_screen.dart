import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../dashboard/app_colors.dart';
import 'report_model.dart';
import 'reports_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ReportsService _service = ReportsService();

  bool _loading = true;
  String? _error;
  CareReport? _report;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final elderId = await SessionManager.getElderId();

      if (elderId == null) {
        throw Exception("Elder ID not found in session.");
      }

      final report = await _service.fetchReportDetail(
        elderId: elderId,
        reportId: widget.reportId,
      );

      if (!mounted) return;

      setState(() {
        _report = report;
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

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Report Detail"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      )
          : _report == null
          ? const Center(child: Text("No report found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                _report!.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "${_formatDate(_report!.periodStart)} - ${_formatDate(_report!.periodEnd)}",
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_report!.elderDayOverview != null)
              _sectionCard(
                title: "Elder's Day Overview",
                icon: Icons.favorite_rounded,
                color: Colors.green,
                child: _overviewContent(_report!.elderDayOverview!),
              ),

            if (_report!.painAreas.isNotEmpty)
              _sectionCard(
                title: "Pain Report",
                icon: Icons.accessibility_new_rounded,
                color: Colors.redAccent,
                child: Text(
                  _report!.painAreas.join(", "),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            if (_report!.activities.isNotEmpty)
              _sectionCard(
                title: "Activities",
                icon: Icons.fitness_center_rounded,
                color: Colors.blue,
                child: Text(
                  _report!.activities.join(", "),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            if ((_report!.aiCheckinInsights ?? "").trim().isNotEmpty)
              _sectionCard(
                title: "AI Check-In Insights",
                icon: Icons.smart_toy_rounded,
                color: Colors.blueAccent,
                child: Text(
                  _report!.aiCheckinInsights!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),

            _sectionCard(
              title: "Medication Adherence",
              icon: Icons.medication_rounded,
              color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Taken: ${_report!.medicationAdherence.takenCount}",
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Missed: ${_report!.medicationAdherence.missedCount}",
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_report!.medicationAdherence.missedItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ..._report!.medicationAdherence.missedItems.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "• $item",
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            _sectionCard(
              title: "Meal Adherence",
              icon: Icons.restaurant_rounded,
              color: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Breakfast: ${_report!.mealAdherence.breakfast ?? 'N/A'}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Lunch: ${_report!.mealAdherence.lunch ?? 'N/A'}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dinner: ${_report!.mealAdherence.dinner ?? 'N/A'}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            if (_report!.concerns.isNotEmpty)
              _sectionCard(
                title: "Concerns",
                icon: Icons.warning_amber_rounded,
                color: Colors.amber.shade700,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _report!.concerns
                      .map(
                        (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "• $c",
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),

            if ((_report!.caregiverRecommendation ?? "").trim().isNotEmpty)
              _sectionCard(
                title: "Caregiver Recommendation",
                icon: Icons.assignment_turned_in_rounded,
                color: AppColors.primary,
                child: Text(
                  _report!.caregiverRecommendation!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _overviewContent(ElderDayOverview o) {
    Widget item(String label, String? value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: "$label: ",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: value ?? "N/A"),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item("Mood", o.mood),
        item("Sleep", o.sleepQuantity),
        item("Water Intake", o.waterIntake),
        item("Appetite", o.appetiteLevel),
        item("Energy", o.energyLevel),
        item("Overall Day", o.overallDay),
        item("Movement", o.movementToday),
        item("Loneliness", o.lonelinessLevel),
        item("Social Interaction", o.talkInteraction),
        item("Stress", o.stressLevel),
      ],
    );
  }
}