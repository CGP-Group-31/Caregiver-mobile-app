import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
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

  @override
  Widget build(BuildContext context) {

    if (elderId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicineRemindersScreen(
                      elderId: elderId!,
                    ),
                  ),
                );
              },
              child: const Text("Create Medicine"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UpdateMedicineScreen(),
                  ),
                );
              },
              child: const Text("Update Medicine"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteMedicineScreen(),
                  ),
                );
              },
              child: const Text("Delete Medicine"),
            ),
          ],
        ),
      ),
    );
  }
}