import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';
import '../auth/theme.dart';
import 'edit_medicine_form.dart';

class UpdateMedicineScreen extends StatefulWidget {
  const UpdateMedicineScreen({super.key});

  @override
  State<UpdateMedicineScreen> createState() => _UpdateMedicineScreenState();
}

class _UpdateMedicineScreenState extends State<UpdateMedicineScreen> {

  List medicines = [];
  bool loading = true;

  Future<void> loadMedicines() async {

    final elderId = await SessionManager.getElderId();

    final response = await DioClient.dio.get(
      "/api/v1/caregiver/medication/elder/$elderId",
    );

    medicines = response.data;

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("Update Medicine"),
        backgroundColor: AppColors.primary,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medicines.length,
        itemBuilder: (context, index) {

          final med = medicines[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),

            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: CircleAvatar(
                backgroundColor: AppColors.sectionBackground,
                child: const Icon(Icons.medication,
                    color: AppColors.primary),
              ),

              title: Text(
                med["name"],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),

              subtitle: Text(
                "Dosage: ${med["dosage"]}",
                style: const TextStyle(
                    color: AppColors.descriptionText),
              ),

              trailing: const Icon(Icons.edit,
                  color: AppColors.primary),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditMedicineScreen(
                      medicineId: med["medicationId"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}