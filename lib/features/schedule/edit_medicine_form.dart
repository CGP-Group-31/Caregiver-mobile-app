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

  @override
  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> loadMedicine() async {
    try {
      final data = await MedicineService.getMedicineById(widget.medicineId);

      nameCtrl.text = (data["name"] ?? "").toString();
      dosageCtrl.text = (data["dosage"] ?? "").toString();
      instructionsCtrl.text = (data["instructions"] ?? "").toString();

      final rawTimes = data["times"] as List? ?? [];
      times = rawTimes.map((e) => e.toString()).toList();

      repeatDays = (data["repeatDays"] ?? "Daily").toString();

      if (data["startDate"] != null) {
        startDate = DateTime.parse(data["startDate"].toString());
      }

      if (data["endDate"] != null) {
        endDate = DateTime.parse(data["endDate"].toString());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      setState(() {
        if (!times.contains(formatted)) {
          times.add(formatted);
          times.sort();
        }
      });
    }
  }

  void removeTime(String time) {
    setState(() {
      times.remove(time);
    });
  }

  Future<void> pickDate(bool isStart) async {
    final initial = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStart ? DateTime.now() : (startDate ?? DateTime.now()),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;

          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> updateMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one reminder time")),
      );
      return;
    }

    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a start date")),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await MedicineService.updateMedicine(
        medicineId: widget.medicineId,
        name: nameCtrl.text.trim(),
        dosage: dosageCtrl.text.trim(),
        instructions: instructionsCtrl.text.trim(),
        times: times,
        repeatDays: repeatDays,
        startDate: DateFormat('yyyy-MM-dd').format(startDate!),
        endDate: endDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(endDate!),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine Updated")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().replaceFirst("Exception: ", "");
      final parts = msg.split("|");
      final userMsg = parts.length > 1 ? parts[1] : msg;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMsg)),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
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

  Widget buildTimeChips() {
    if (times.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "No times added yet",
          style: TextStyle(color: AppColors.textShade),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => removeTime(time),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
                  offset: const Offset(0, 5),
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
                    "Reminder Times",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: pickTime,
                      icon: const Icon(Icons.add_alarm, color: Colors.white),
                      label: const Text(
                        "Add Time (24H)",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildTimeChips(),
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
                  DropdownButtonFormField<String>(
                    value: repeatDays,
                    items: const [
                      DropdownMenuItem(
                        value: "Daily",
                        child: Text("Daily"),
                      ),
                      DropdownMenuItem(
                        value: "EveryOtherDay",
                        child: Text("Every Other Day"),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        repeatDays = v ?? "Daily";
                      });
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: saving ? null : updateMedicine,
                      child: saving
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
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