import 'package:flutter/material.dart';
import '../auth/theme.dart';
import 'elder_service.dart';

class HealthDetailsPage extends StatefulWidget {
  const HealthDetailsPage({super.key});

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
  late Future<Map<String, dynamic>> _medicalProfileFuture;
  late Future<Map<String, dynamic>> _preferredDoctorFuture;

  @override
  void initState() {
    super.initState();
    _medicalProfileFuture = ElderService.getMedicalProfile();
    _preferredDoctorFuture = ElderService.getPreferredDoctor();
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
            tabs: [
              Tab(text: "Vitals"),
              Tab(text: "Medical History"),
            ],
          ),
        ),
        body: FutureBuilder(
          future: Future.wait([_medicalProfileFuture, _preferredDoctorFuture]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final medicalData = snapshot.data?[0] ?? {};
            final doctorData = snapshot.data?[1] ?? {};

            return TabBarView(
              children: [
                _buildVitalsTab(medicalData),
                _buildMedicalHistoryTab(medicalData, doctorData),
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
        _buildEditTile("Hydration Level", data['hydration'] ?? "Good", Icons.water_drop, () {}),
        _buildEditTile("Blood Pressure", data['bp'] ?? "120/80", Icons.speed, () {}),
        _buildEditTile("Blood Sugar", data['sugar'] ?? "90 mg/dL", Icons.opacity, () {}),
        _buildEditTile("Heart Rate", data['heart_rate'] ?? "72 bpm", Icons.favorite, () {}),
        _buildEditTile("Weight", data['weight'] ?? "70 kg", Icons.monitor_weight, () {}),
      ],
    );
  }

  Widget _buildMedicalHistoryTab(Map<String, dynamic> medicalData, Map<String, dynamic> doctorData) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildEditTile("Blood Type", medicalData['blood_type'] ?? "A+", Icons.bloodtype, () {}),
        _buildEditTile("Allergies", medicalData['allergies'] ?? "None", Icons.warning_amber, () {}),
        _buildEditTile("Chronic Conditions", medicalData['chronic'] ?? "None", Icons.history, () {}),
        _buildEditTile("Important Notes", medicalData['notes'] ?? "None", Icons.note_alt, () {}),
        _buildEditTile("Past Surgeries", medicalData['surgeries'] ?? "None", Icons.medical_services, () {}),
        
        // DISPLAY DOCTOR NAME FROM THE NEW API
        _buildEditTile(
          "Preferred Doctor", 
          doctorData['DoctorName'] ?? "None Assigned", 
          Icons.person, 
          () {}
        ),
      ],
    );
  }

  Widget _buildEditTile(String title, String value, IconData icon, VoidCallback onEdit) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.descriptionText)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        trailing: IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
      ),
    );
  }
}
