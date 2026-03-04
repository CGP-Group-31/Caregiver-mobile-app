import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';
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
      appBar: AppBar(
        title: const Text("Select Medicine to Update"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {

          final med = medicines[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),

            child: ListTile(
              title: Text(med["name"]),
              subtitle: Text("Dosage: ${med["dosage"]}"),
              trailing: const Icon(Icons.edit),

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