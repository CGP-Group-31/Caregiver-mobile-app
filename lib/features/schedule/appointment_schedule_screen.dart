import 'package:flutter/material.dart';
import '../auth/theme.dart';
import 'create_appointment_screen.dart';
import 'delete_appointment_screen.dart';

class AppointmentScheduleScreen extends StatelessWidget {
  const AppointmentScheduleScreen({super.key});

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [

            buildCard(
              icon: Icons.add,
              title: "Create Appointment",
              subtitle: "Add doctor appointment",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateAppointmentScreen(),
                  ),
                );
              },
            ),
            buildCard(
              icon: Icons.delete,
              title: "Delete Appointment",
              subtitle: "Remove appointment",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteAppointmentScreen(),
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