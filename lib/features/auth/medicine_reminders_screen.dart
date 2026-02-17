import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/session/session_manager.dart';
import 'medicine_service.dart';

class MedicineRemindersScreen extends StatefulWidget {
  const MedicineRemindersScreen({super.key});

  @override
  State<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState
    extends State<MedicineRemindersScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();

  TimeOfDay? selectedTime;
  DateTime? startDate;
  DateTime? endDate;

  bool isDaily = false;
  List<String> selectedDays = [];

  bool loading = false;

  final List<String> weekDays = [
    "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
  ];

  // ================= TIME PICKER =================
  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  // ================= DATE PICKER =================
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

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTime == null ||
        startDate == null ||
        endDate == null ||
        (!isDaily && selectedDays.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final caregiverId = await SessionManager.getUserId();
      final elderId = await SessionManager.getElderId();

      if (caregiverId == null || elderId == null) {
        throw Exception("Session expired. Login again.");
      }

      final formattedTime =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

      final repeatDaysString =
      isDaily ? "Daily" : selectedDays.join(",");

      await MedicineService.createMedicine(
        elderId: elderId,
        caregiverId: caregiverId,
        name: nameCtrl.text.trim(),
        dosage: dosageCtrl.text.trim(), // STRING
        instructions: instructionsCtrl.text.trim(),
        time: formattedTime,
        repeatDays: repeatDaysString, // STRING
        startDate: DateFormat('yyyy-MM-dd').format(startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(endDate!),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine created successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    instructionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medicine"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Medicine Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: dosageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Dosage (Quantity)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (int.tryParse(v) == null) return "Enter valid number";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: instructionsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Instructions",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 20),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide()),
                title: Text(selectedTime == null
                    ? "Select Time (24h)"
                    : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"),
                trailing: const Icon(Icons.access_time),
                onTap: pickTime,
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text("Repeat Daily"),
                value: isDaily,
                onChanged: (val) {
                  setState(() {
                    isDaily = val;
                    if (val) selectedDays.clear();
                  });
                },
              ),

              if (!isDaily)
                Wrap(
                  spacing: 8,
                  children: weekDays.map((day) {
                    final selected = selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide()),
                title: Text(startDate == null
                    ? "Select Start Date"
                    : DateFormat('yyyy-MM-dd').format(startDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(true),
              ),

              const SizedBox(height: 12),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide()),
                title: Text(endDate == null
                    ? "Select End Date"
                    : DateFormat('yyyy-MM-dd').format(endDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(false),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("Save Medicine"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
