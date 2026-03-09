import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_manager.dart';
import '../auth/theme.dart';

class DeleteAppointmentScreen extends StatefulWidget {
  const DeleteAppointmentScreen({super.key});

  @override
  State<DeleteAppointmentScreen> createState() =>
      _DeleteAppointmentScreenState();
}

class _DeleteAppointmentScreenState extends State<DeleteAppointmentScreen> {
  List appointments = [];
  bool loading = true;

  Future<void> loadAppointments() async {
    final elderId = await SessionManager.getElderId();

    final res = await DioClient.dio.get(
      "/api/v1/caregiver/appointments/elder/$elderId",
    );

    appointments = res.data;

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    await DioClient.dio.delete(
      "/api/v1/caregiver/appointments/$id",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment deleted")),
    );

    loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("Delete Appointment"),
        backgroundColor: AppColors.primary,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final a = appointments[index];

          return Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: ListTile(
              title: Text(
                a["title"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),

              subtitle: Text(
                a["doctor_name"],
                style:
                const TextStyle(color: AppColors.descriptionText),
              ),

              trailing: IconButton(
                icon: const Icon(Icons.delete,
                    color: AppColors.sosButton),
                onPressed: () =>
                    deleteAppointment(a["appointment_id"]),
              ),
            ),
          );
        },
      ),
    );
  }
}