import 'package:flutter/material.dart';
import 'elder_service.dart';
import '../auth/theme.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  late Future<Map<String, dynamic>> _medicalProfileFuture;

  @override
  void initState() {
    super.initState();
    _medicalProfileFuture = ElderService.getMedicalProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Medical Background", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _medicalProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _medicalProfileFuture = ElderService.getMedicalProfile()),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? {};

          // Flexible key mapping (no decryption)
          String getValue(List<String> keys) {
            for (var key in keys) {
              if (data.containsKey(key) && data[key] != null && data[key].toString().isNotEmpty) {
                return data[key].toString();
              }
            }
            return "None";
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildInfoCard("Blood Type", getValue(['blood_type', 'BloodType', 'bloodType']), Icons.bloodtype),
              _buildInfoCard("Allergies", getValue(['allergies', 'Allergies']), Icons.warning_amber),
              _buildInfoCard("Chronic Conditions", getValue(['chronic_conditions', 'ChronicConditions', 'chronicConditions']), Icons.history),
              _buildInfoCard("Past Surgeries", getValue(['past_surgeries', 'PastSurgeries', 'pastSurgeries']), Icons.medical_services),
              _buildInfoCard("Emergency Notes", getValue(['emergency_notes', 'EmergencyNotes', 'emergencyNotes']), Icons.note_alt),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.descriptionText)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
      ),
    );
  }
}
