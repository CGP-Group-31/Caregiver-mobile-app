import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../dashboard/app_colors.dart';
import '../dashboard/settings_screen.dart';
import '../dashboard/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();

  bool _loading = true;
  String? _error;

  String _caregiverName = "Caregiver";
  List<dynamic> _alerts = [];

  @override
  void initState(){
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async{
    setState(() {
      _loading = true;
      _error = null;
    });

    final caregiverId = await SessionManager.getUserId(); //caregiver id
    final elderId = await SessionManager.getElderId(); // elder id

    final localName = await SessionManager.getFullName();
    if (localName != null && localName.trim().isNotEmpty){
      _caregiverName = localName.trim();
    }

    if(caregiverId == null || elderId == null){
      await SessionManager.debugPrintSession(tag: "DASHBOARD");
      setState(() {
        _loading = false;
        _error =
            "Missing session data (caregiverId or elderId). Please login again.";
      });
      return;
    }
    try {
      final data = await _service.fetchDashboardHome(
        elderId: elderId,
        caregiverId: caregiverId,
      );

      setState(() {
        _caregiverName =
            (data["caregiver_name"] ?? data["full_name"] ?? _caregiverName)
                .toString();

        _alerts = (data["quick_alerts"] as List<dynamic>?) ?? [];
        _loading = false;
      });
    } catch (e){
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  IconData _iconForType(String type){
    switch (type){
      case "missed_medicine":
        return Icons.medication;
      case "missed_checkin":
        return Icons.access_time;
      case "low_hydration":
        return Icons.water_drop;
      case "upcoming_appointment":
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorView()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _loadDashboard,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Welcome, $_caregiverName 👋",
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ///AI summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.containerBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Last AI Check in Summary",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text("AI summary will appear here once connected."),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        ///Quick Alerts
                        const Text(
                          "Quick Alerts",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (_alerts.isEmpty)
                          const Text(
                            "No alerts right now.",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),

                        ..._alerts.map((a) {
                          final title = a["title"]?.toString() ?? "Alert";
                          final subtitle = a["subtitle"]?.toString() ?? "";
                          final type = a["type"]?.toString() ?? "";

                          return _alertTitle(
                            title: title,
                            subtitle: subtitle,
                            icon: _iconForType(type),
                            color: AppColors.warning,
                          );
                        }),
                      ],
                    ),
                ),
      ),
    );
  }

  Widget _errorView(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Couldn't load dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertTitle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.containerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
