import 'package:flutter/material.dart';
import '../auth/theme.dart';
import '../schedule/schedule_screen.dart';


class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("More"),
        backgroundColor: AppColors.primary,
      ),

      body: ListView(
        children: [

          const SizedBox(height: 20),

          buildOption(
            icon: Icons.schedule,
            title: "Schedule",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScheduleScreen(),
                ),
              );
            },
          ),

          buildOption(
            icon: Icons.message,
            title: "Messages",
            onTap: () {
              // Navigate to messages page later
            },
          ),

          buildOption(
            icon: Icons.settings,
            title: "Settings",
            onTap: () {},
          ),

          buildOption(
            icon: Icons.person,
            title: "Caregiver Profile",
            onTap: () {},
          ),

          buildOption(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}