import 'package:flutter/material.dart';
import '../auth/theme.dart';
import 'elder_service.dart';
import '../../core/utils/encryption_utils.dart';

class HealthDetailsPage extends StatefulWidget {
  const HealthDetailsPage({super.key});

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
  late Future<Map<String, dynamic>> _medicalProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _medicalProfileFuture = ElderService.getMedicalProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.mainBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text("Health Details", style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Vitals"),
              Tab(text: "Medical History"),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _medicalProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final data = snapshot.data ?? {};

            return TabBarView(
              children: [
                _buildVitalsTab(data),
                _buildMedicalHistoryTab(data),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVitalsTab(Map<String, dynamic> data) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard("Hydration Level", data['hydration_level']?.toString() ?? "Good", Icons.water_drop, onEdit: () {}),
        _buildInfoCard("Blood Pressure", data['blood_pressure']?.toString() ?? "120/80", Icons.speed, onEdit: () {}),
        _buildInfoCard("Blood Sugar", data['blood_sugar']?.toString() ?? "90 mg/dL", Icons.opacity, onEdit: () {}),
        _buildInfoCard("Heart Rate", data['heart_rate']?.toString() ?? "72 bpm", Icons.favorite, onEdit: () {}),
        _buildInfoCard("Weight", data['weight']?.toString() ?? "70 kg", Icons.monitor_weight, onEdit: () {}),
      ],
    );
  }

  Widget _buildMedicalHistoryTab(Map<String, dynamic> data) {
    String getDecrypted(List<String> keys) {
      for (var key in keys) {
        if (data.containsKey(key) && data[key] != null && data[key].toString().isNotEmpty) {
          return EncryptionUtils.decrypt(data[key].toString());
        }
      }
      return "None";
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard("Blood Type", getDecrypted(['blood_type', 'BloodType']), Icons.bloodtype, onEdit: () {}),
        _buildInfoCard("Allergies", getDecrypted(['allergies', 'Allergies']), Icons.warning_amber, onEdit: () {}),
        _buildInfoCard("Chronic Conditions", getDecrypted(['chronic_conditions', 'ChronicConditions']), Icons.history, onEdit: () {}),
        _buildInfoCard("Important Notes", getDecrypted(['emergency_notes', 'EmergencyNotes']), Icons.note_alt, onEdit: () {}),
        _buildInfoCard("Past Surgeries", getDecrypted(['past_surgeries', 'PastSurgeries']), Icons.medical_services, onEdit: () {}),
        _buildInfoCard("Preferred Doctor", "Dr. Smith", Icons.person, onEdit: () {}),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, {required VoidCallback onEdit}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.descriptionText, fontWeight: FontWeight.w500)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primaryText,
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
