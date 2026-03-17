import 'package:flutter/material.dart';
import '../../../core/session/session_manager.dart';
import '../auth/theme.dart';
import 'appointment_service.dart';

class DeleteAppointmentScreen extends StatefulWidget {
  const DeleteAppointmentScreen({super.key});

  @override
  State<DeleteAppointmentScreen> createState() =>
      _DeleteAppointmentScreenState();
}

class _DeleteAppointmentScreenState extends State<DeleteAppointmentScreen> {

  List appointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {

    final elderId = await SessionManager.getElderId();

    if (elderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Elder ID not found")),
      );
      return;
    }

    final data = await AppointmentService.getAppointments(elderId);

    setState(() {
      appointments = data;
      loading = false;
    });
  }

  Future<void> deleteAppointment(int id) async {

    await AppointmentService.deleteAppointment(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment deleted successfully")),
    );

    loadAppointments();
  }

  void confirmDelete(int id) {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Delete Appointment"),
          content: const Text(
              "Are you sure you want to delete this appointment?"),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteAppointment(id);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),

          ],
        );
      },
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
          "Delete Appointment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
          ? const Center(
        child: Text(
          "No Appointments Found",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {

          final a = appointments[index];

          return Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8
            ),

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
                a["Title"] ?? "No Title",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),

              subtitle: Text(
                "Doctor: ${a["DoctorName"] ?? "Unknown"}",
                style: const TextStyle(
                    color: AppColors.descriptionText
                ),
              ),

              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: AppColors.sosButton,
                ),
                onPressed: () =>
                    confirmDelete(a["AppointmentID"]),
              ),

            ),
          );
        },
      ),
    );
  }
}