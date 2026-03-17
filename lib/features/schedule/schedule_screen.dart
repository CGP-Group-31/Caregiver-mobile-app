import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../auth/theme.dart';
import 'update_medicine_screen.dart';
import 'delete_medicine_screen.dart';
import 'medicine_reminders_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

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

  Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0,5),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.sectionBackground,
          child: Icon(icon, color: AppColors.primary),
        ),

        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryText),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.descriptionText),
        ),

        trailing: const Icon(Icons.arrow_forward_ios,size:16)
        ,

        onTap: onTap,
      ),
    );
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
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Medication Schedule",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            buildCard(
              icon: Icons.add_circle_outline,
              title: "Create Medicine",
              subtitle: "Add a new medication schedule",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MedicineRemindersScreen(elderId: elderId!),
                  ),
                );
              },
            ),
            buildCard(
              icon: Icons.edit_calendar,
              title: " View & Update Medicine",
              subtitle: "Edit an existing medicine schedule",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UpdateMedicineScreen(),
                  ),
                );
              },
            ),

            buildCard(
              icon: Icons.delete_outline,
              title: "Delete Medicine",
              subtitle: "Remove a medicine schedule",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteMedicineScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}