import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../auth/theme.dart';
import 'schedule_screen.dart';

class MainScheduleScreen extends StatefulWidget {
  const MainScheduleScreen({super.key});

  @override
  State<MainScheduleScreen> createState() => _MainScheduleScreenState();
}

class _MainScheduleScreenState extends State<MainScheduleScreen> {

  int? elderId;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final id = await SessionManager.getElderId();
    setState(() {
      elderId = id;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (elderId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("Schedule"),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            _scheduleCard(
              icon: Icons.medication,
              title: "Medicine",
              subtitle: "Manage medication ",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScheduleScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// APPOINTMENTS BUTTON
            _scheduleCard(
              icon: Icons.calendar_month,
              title: "Appointments",
              subtitle: "Doctor visits & reminders",
              onTap: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Appointments page coming soon")),
                );

              },
            ),

            const SizedBox(height: 20),

            /// MEALS & HYDRATION
            _scheduleCard(
              icon: Icons.restaurant,
              title: "Meals & Hydration",
              subtitle: "Track food and water intake",
              onTap: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Meals & Hydration page coming soon")),
                );

              },
            ),

          ],
        ),
      ),
    );
  }

  /// CARD WIDGET
  Widget _scheduleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {

    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: AppColors.containerBackground,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0,5),
            )
          ],
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: AppColors.sectionBackground,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
                size: 28,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.descriptionText,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textShade,
            )
          ],
        ),
      ),
    );
  }
}