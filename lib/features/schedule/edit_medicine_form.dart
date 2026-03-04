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

  Widget inputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textShade),
        filled: true,
        fillColor: AppColors.sectionBackground,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget dateTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text(title),
        onTap: onTap,
      ),
    );
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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0,5),
                )
              ],
            ),

            child: Form(
              key: _formKey,

              child: ListView(
                children: [

                  inputField(
                    controller: nameCtrl,
                    label: "Medicine Name",
                  ),

                  const SizedBox(height: 16),

                  inputField(
                    controller: dosageCtrl,
                    label: "Dosage",
                  ),

                  const SizedBox(height: 16),

                  inputField(
                    controller: instructionsCtrl,
                    label: "Instructions",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Reminder Time",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: pickTime,
                    icon: const Icon(Icons.access_time, color: Colors.white),
                    label: Text(
                      times.isEmpty
                          ? "Select Time"
                          : "Time: ${times.first}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Duration",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  dateTile(
                    title: startDate == null
                        ? "Select Start Date"
                        : DateFormat('yyyy-MM-dd').format(startDate!),
                    onTap: () => pickDate(true),
                  ),

                  const SizedBox(height: 10),

                  dateTile(
                    title: endDate == null
                        ? "Select End Date"
                        : DateFormat('yyyy-MM-dd').format(endDate!),
                    onTap: () => pickDate(false),
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
                    decoration: InputDecoration(
                      labelText: "Repeat",
                      filled: true,
                      fillColor: AppColors.sectionBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: saving ? null : updateMedicine,
                      child: saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Update Medicine",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}