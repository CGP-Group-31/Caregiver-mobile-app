import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/session/session_manager.dart';
import 'medicine_service.dart';
import '../auth/theme.dart';

class MedicineRemindersScreen extends StatefulWidget {
  final int elderId;

  const MedicineRemindersScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState extends State<MedicineRemindersScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();

  List<TimeOfDay> selectedTimes = [];

  DateTime? startDate;
  DateTime? endDate;

  String repeatMode = "Daily";
  List<String> selectedDays = [];

  bool loading = false;

  final List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  // ADD TIME
  Future<void> addTime() async {
    if (selectedTimes.length >= 6) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data:
          MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTimes.add(picked));
    }
  }

  void removeTime(int index) {
    setState(() => selectedTimes.removeAt(index));
  }

  // DATE PICKER
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

          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  // FORMAT TIMES
  List<String> getFormattedTimes() {
    final formatted = selectedTimes.map((t) {
      final h = t.hour.toString().padLeft(2, '0');
      final m = t.minute.toString().padLeft(2, '0');
      return "$h:$m";
    }).toList();

    final unique = formatted.toSet().toList();
    unique.sort();
    return unique;
  }

  // BUILD REPEAT STRING
  String buildRepeatString() {
    if (repeatMode == "Daily") return "Daily";
    if (repeatMode == "EveryOtherDay") return "EveryOtherDay";

    final order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final uniqueDays = selectedDays.toSet().toList();
    uniqueDays.sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));

    return uniqueDays.join(",");
  }

  void clearForm() {
    nameCtrl.clear();
    dosageCtrl.clear();
    instructionsCtrl.clear();
    selectedTimes.clear();
    startDate = null;
    endDate = null;
    repeatMode = "Daily";
    selectedDays.clear();

    setState(() {});
  }

  // SUBMIT MEDICINE
  Future<void> submitMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTimes.isEmpty || startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select time and start date")),
      );
      return;
    }

    if (repeatMode == "Custom" && selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one day")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final caregiverId = await SessionManager.getUserId();

      if (caregiverId == null) {
        throw Exception("Caregiver session not found");
      }

      final startDateFormatted = DateFormat('yyyy-MM-dd').format(startDate!);

      final endDateFormatted =
      endDate == null ? null : DateFormat('yyyy-MM-dd').format(endDate!);

      await MedicineService.createMedicine(
        elderId: widget.elderId,
        caregiverId: caregiverId,
        name: nameCtrl.text.trim(),
        dosage: dosageCtrl.text.trim(),
        instructions: instructionsCtrl.text.trim(),
        times: getFormattedTimes(),
        repeatDays: buildRepeatString(),
        startDate: startDateFormatted,
        endDate: endDateFormatted,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine added")),
      );

      clearForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() => loading = false);
    }
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
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          "Add Medicines",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _sectionTitle("Medicine Details"),

                        _buildInputField(
                          controller: nameCtrl,
                          label: "Medicine Name",
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? "Medicine name required"
                              : null,
                        ),

                        const SizedBox(height: 15),

                        _buildInputField(
                          controller: dosageCtrl,
                          label: "Dosage",
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? "Dosage required"
                              : null,
                        ),

                        const SizedBox(height: 15),

                        _buildInputField(
                          controller: instructionsCtrl,
                          label: "Instructions",
                          maxLines: 3,
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? "Instructions required"
                              : null,
                        ),

                        const SizedBox(height: 30),

                        _sectionTitle("Reminder Times"),

                        ...selectedTimes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final time = entry.value;

                          final formatted =
                              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                          return ListTile(
                            title: Text(formatted),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => removeTime(index),
                            ),
                          );
                        }),

                        if (selectedTimes.length < 6)
                          ElevatedButton(
                            onPressed: addTime,
                            child: const Text("Add Time"),
                          ),

                        const SizedBox(height: 20),

                        _sectionTitle("Duration"),

                        _buildDateTile(
                          title: startDate == null
                              ? "Select Start Date"
                              : DateFormat('yyyy-MM-dd').format(startDate!),
                          onTap: () => pickDate(true),
                        ),

                        const SizedBox(height: 10),

                        _buildDateTile(
                          title: endDate == null
                              ? "Select End Date (optional)"
                              : DateFormat('yyyy-MM-dd').format(endDate!),
                          onTap: () => pickDate(false),
                        ),

                        const SizedBox(height: 30),

                        _sectionTitle("Repeat"),

                        RadioListTile(
                          title: const Text("Daily"),
                          value: "Daily",
                          groupValue: repeatMode,
                          onChanged: (v) =>
                              setState(() => repeatMode = v!),
                        ),

                        RadioListTile(
                          title: const Text("Every Other Day"),
                          value: "EveryOtherDay",
                          groupValue: repeatMode,
                          onChanged: (v) =>
                              setState(() => repeatMode = v!),
                        ),

                        RadioListTile(
                          title: const Text("Specific Days"),
                          value: "Custom",
                          groupValue: repeatMode,
                          onChanged: (v) =>
                              setState(() => repeatMode = v!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  ElevatedButton(
                    onPressed: loading ? null : submitMedicine,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Save Medicine"),
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDateTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      leading: const Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }
}