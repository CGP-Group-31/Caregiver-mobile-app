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

  // 🔴 Backend Field Errors
  String? nameError;
  String? dosageError;
  String? instructionsError;
  String? timeError;
  String? startDateError;
  String? endDateError;
  String? repeatDaysError;

  final List<String> weekDays = [
    "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
  ];

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

  void clearErrors() {
    nameError = null;
    dosageError = null;
    instructionsError = null;
    timeError = null;
    startDateError = null;
    endDateError = null;
    repeatDaysError = null;
  }

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

    setState(() {
      loading = true;
      clearErrors();
    });

    try {
      final caregiverId = await SessionManager.getUserId();
      final elderId = await SessionManager.getElderId();

      final formattedTime =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

      final startDateFormatted =
      DateFormat('yyyy-MM-dd').format(startDate!);

      final endDateFormatted =
      DateFormat('yyyy-MM-dd').format(endDate!);

      final repeatDaysString = isDaily
          ? "Mon,Tue,Wed,Thu,Fri,Sat,Sun"
          : selectedDays.join(",");

      await MedicineService.createMedicine(
        elderId: elderId!,
        caregiverId: caregiverId!,
        name: nameCtrl.text.trim(),
        dosage: dosageCtrl.text.trim(), // ✅ STRING
        instructions: instructionsCtrl.text.trim(),
        time: formattedTime,
        repeatDays: repeatDaysString,
        startDate: startDateFormatted,
        endDate: endDateFormatted,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine created successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      final error = e.toString().replaceFirst("Exception: ", "");

      if (error.contains("|")) {
        final parts = error.split("|");
        final field = parts[0];
        final message = parts[1];

        setState(() {
          switch (field) {
            case "name":
              nameError = message;
              break;
            case "dosage":
              dosageError = message;
              break;
            case "instructions":
              instructionsError = message;
              break;
            case "time":
              timeError = message;
              break;
            case "startDate":
              startDateError = message;
              break;
            case "endDate":
              endDateError = message;
              break;
            case "repeatDays":
              repeatDaysError = message;
              break;
            default:
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
          }
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
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
                decoration: InputDecoration(
                  labelText: "Medicine Name",
                  border: const OutlineInputBorder(),
                  errorText: nameError,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: dosageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Dosage (Quantity)",
                  border: const OutlineInputBorder(),
                  errorText: dosageError,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: instructionsCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Instructions",
                  border: const OutlineInputBorder(),
                  errorText: instructionsError,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                title: Text(
                  selectedTime == null
                      ? "Select Time (24h)"
                      : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: pickTime,
              ),

              if (timeError != null)
                Text(timeError!, style: const TextStyle(color: Colors.red)),

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

              const SizedBox(height: 20),

              ListTile(
                title: Text(
                  startDate == null
                      ? "Select Start Date"
                      : DateFormat('yyyy-MM-dd').format(startDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(true),
              ),

              if (startDateError != null)
                Text(startDateError!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 12),

              ListTile(
                title: Text(
                  endDate == null
                      ? "Select End Date"
                      : DateFormat('yyyy-MM-dd').format(endDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(false),
              ),

              if (endDateError != null)
                Text(endDateError!, style: const TextStyle(color: Colors.red)),

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
