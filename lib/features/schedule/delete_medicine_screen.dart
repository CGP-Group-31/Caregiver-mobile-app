import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';
import '../auth/theme.dart';

class DeleteMedicineScreen extends StatefulWidget {
  const DeleteMedicineScreen({super.key});

  @override
  State<DeleteMedicineScreen> createState() => _DeleteMedicineScreenState();
}

class _DeleteMedicineScreenState extends State<DeleteMedicineScreen> {

  List medicines = [];
  bool loading = true;

  Future<void> loadMedicines() async {

    final elderId = await SessionManager.getElderId();

    final response =
    await DioClient.dio.get("/api/v1/caregiver/medication/elder/$elderId");

    medicines = response.data;

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  Future<void> deleteMedicine(int medicationId) async {

    await DioClient.dio.delete(
      "/api/v1/caregiver/medication/delete/$medicationId",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medicine deleted")),
    );

    loadMedicines();
  }

  // ⭐ Confirmation Dialog
  void confirmDelete(int medicationId) {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Delete Medicine"),
          content: const Text(
              "Are you sure you want to delete this medicine?"),
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
                deleteMedicine(medicationId);
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
        title: const Text("Delete Medicine"),
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
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: CircleAvatar(
                backgroundColor: AppColors.sectionBackground,
                child: const Icon(
                  Icons.medication,
                  color: AppColors.primary,
                ),
              ),

              title: Text(
                med["name"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),

              subtitle: Text(
                "Dosage: ${med["dosage"]}",
                style: const TextStyle(
                  color: AppColors.descriptionText,
                ),
              ),

              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: AppColors.sosButton,
                ),
                onPressed: () =>
                    confirmDelete(med["medicationId"]),
              ),
            ),
          );
        },
      ),
    );
  }
}