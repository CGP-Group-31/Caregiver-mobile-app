import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../auth/theme.dart';
import 'medicine_service.dart';

class EditMedicineScreen extends StatefulWidget {

  final int medicineId;

  const EditMedicineScreen({
    super.key,
    required this.medicineId,
  });

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();

  List<String> times = [];

  DateTime? startDate;
  DateTime? endDate;

  String repeatDays = "Daily";

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadMedicine();
  }

  Future<void> loadMedicine() async {

    final data = await MedicineService.getMedicineById(widget.medicineId);

    nameCtrl.text = data["name"];
    dosageCtrl.text = data["dosage"];
    instructionsCtrl.text = data["instructions"];

    times = List<String>.from(data["times"]);
    repeatDays = data["repeatDays"];

    startDate = DateTime.parse(data["startDate"]);

    if (data["endDate"] != null) {
      endDate = DateTime.parse(data["endDate"]);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> pickTime() async {

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {

      final formatted =
          "${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}";

      setState(() {
        times.clear();
        times.add(formatted);
      });
    }
  }

  Future<void> pickDate(bool isStart) async {

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {

      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> updateMedicine() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      saving = true;
    });

    await MedicineService.updateMedicine(
      medicineId: widget.medicineId,
      name: nameCtrl.text,
      dosage: dosageCtrl.text,
      instructions: instructionsCtrl.text,
      times: times,
      repeatDays: repeatDays,
      startDate: DateFormat('yyyy-MM-dd').format(startDate!),
      endDate: endDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(endDate!),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Medicine Updated")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        title: const Text("Edit Medicine"),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              TextFormField(
                controller: nameCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: const InputDecoration(
                  labelText: "Medicine Name",
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: dosageCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: const InputDecoration(
                  labelText: "Dosage",
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: instructionsCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: const InputDecoration(
                  labelText: "Instructions",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickTime,
                child: Text(
                  times.isEmpty
                      ? "Select Time"
                      : "Time: ${times.first}",
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () => pickDate(true),
                child: Text(
                  startDate == null
                      ? "Start Date"
                      : DateFormat('yyyy-MM-dd').format(startDate!),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () => pickDate(false),
                child: Text(
                  endDate == null
                      ? "End Date"
                      : DateFormat('yyyy-MM-dd').format(endDate!),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: repeatDays,
                items: const [
                  DropdownMenuItem(value: "Daily", child: Text("Daily")),
                  DropdownMenuItem(
                      value: "EveryOtherDay",
                      child: Text("Every Other Day")),
                ],
                onChanged: (v) {
                  repeatDays = v.toString();
                },
                decoration: const InputDecoration(
                  labelText: "Repeat",
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: saving ? null : updateMedicine,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text("Update Medicine"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}