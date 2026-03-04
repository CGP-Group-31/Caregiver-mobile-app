import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Delete Medicine")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {

          final med = medicines[index];

          return ListTile(
            title: Text(med["name"]),
            subtitle: Text("Dosage: ${med["dosage"]}"),

            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteMedicine(med["medicationId"]),
            ),
          );
        },
      ),
    );
  }
}