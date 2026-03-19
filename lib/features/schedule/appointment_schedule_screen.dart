import 'package:flutter/material.dart';
import '../../../core/session/session_manager.dart';
import '../auth/theme.dart';
import 'create_appointment_screen.dart';
import 'delete_appointment_screen.dart';
import 'appointment_service.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  const AppointmentScheduleScreen({super.key});

  @override
  State<AppointmentScheduleScreen> createState() => _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {

  List appointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() {
      loading = true;
      appointments = [];
    });

    try {
      final elderId = await SessionManager.getElderId();

      if (elderId == null) return;

      final data = await AppointmentService.getAppointments(elderId);

      setState(() {
        appointments = data;
      });

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {
      setState(() => loading = false);
    }
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
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(18),

        leading: CircleAvatar(
          backgroundColor: AppColors.sectionBackground,
          child: Icon(icon,color: AppColors.primary),
        ),

        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText)),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios,size:16),

        onTap: onTap,
      ),
    );
  }

  Widget appointmentItem(Map a) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          backgroundColor: AppColors.sectionBackground,
          child: const Icon(Icons.calendar_today, color: AppColors.primary),
        ),

        title: Text(
          a["Title"] ?? "No Title",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),

        subtitle: Text(
          "Doctor: ${a["DoctorName"] ?? "Unknown"}\n"
          "Hospital :${a["Location"] ?? "Unknown"}\n"
              "${a["AppointmentDate"] ?? ""}  ${a["AppointmentTime"] ?? ""}",
          style: const TextStyle(color: AppColors.descriptionText),
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Appointment Schedule",
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

            buildCard(
              icon: Icons.add,
              title: "Create Appointment",
              subtitle: "Add doctor appointment",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateAppointmentScreen(),
                  ),
                );

                if (mounted) {
                  loadAppointments();
                }
              },
            ),

            buildCard(
              icon: Icons.delete,
              title: "Delete Appointment",
              subtitle: "Remove appointment",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteAppointmentScreen(),
                  ),
                );

                if (mounted) {
                  loadAppointments();
                }
              },
            ),

            const SizedBox(height: 10),

            const Text(
              "Upcoming 7 Days",
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
                  : appointments.isEmpty
                  ? const Center(
                child: Text(
                  "No upcoming appointments",
                  style: TextStyle(fontSize: 14),
                ),
              )
                  : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return appointmentItem(appointments[index]);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}