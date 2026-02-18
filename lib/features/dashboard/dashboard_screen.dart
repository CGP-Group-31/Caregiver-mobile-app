import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../auth/login_screen.dart';
import '../dashboard/app_colors.dart';
import '../dashboard/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionManager.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ///Header
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

              const SizedBox(height: 10),

              const Text(
                "Welcome, Sarah 👋",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              ///AI Summary check in part
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.containerBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Last AI Check in Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 10),
                    Text("* John was last active at the living room."),
                    Text("* Hydration level lower than that of the usual."),
                    Text("* Missed morning medicine at 8:00 AM"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ///Quick alerts
              const Text(
                "Quick Alerts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              _alertTile(
                title: "Missed Medicine",
                subtitle: "Today, 8:30AM",
                icon: Icons.medication,
                color: AppColors.warning,
              ),

              _alertTile(
                title: "Missed Check In",
                subtitle: "Tuesday, 5:15PM",
                icon: Icons.access_time,
                color: AppColors.warning,
              ),

              _alertTile(
                title: "Low Hydration",
                subtitle: "Hydration level lower than usual",
                icon: Icons.water_drop,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertTile({
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
          Icon(icon, color: color,),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
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
