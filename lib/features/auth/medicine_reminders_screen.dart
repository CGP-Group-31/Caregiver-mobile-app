import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/session/session_manager.dart';
import 'medicine_service.dart';
import 'next_page.dart';

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

  List<TimeOfDay> selectedTimes = [];
  DateTime? startDate;
  DateTime? endDate;

  String repeatMode = "Daily"; // Daily, EveryOtherDay, Custom
  List<String> selectedDays = [];

  bool loading = false;

  final List<String> weekDays = [
    "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
  ];

  Future<void> addTime() async {
    if (selectedTimes.length >= 6) return;

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
      setState(() => selectedTimes.add(picked));
    }
  }

  void removeTime(int index) {
    setState(() => selectedTimes.removeAt(index));
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

  List<String> getFormattedTimes() {
    return selectedTimes.map((t) {
      return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
    }).toList();
  }

  String buildRepeatString() {
    if (repeatMode == "Daily") return "Daily";
    if (repeatMode == "EveryOtherDay") return "EveryOtherDay";
    return selectedDays.join(",");
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
      final elderId = await SessionManager.getElderId();

      final startDateFormatted =
      DateFormat('yyyy-MM-dd').format(startDate!);

      final endDateFormatted = endDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(endDate!);

      await MedicineService.createMedicine(
        elderId: elderId!,
        caregiverId: caregiverId!,
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
  void goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NextPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medicines"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: dosageCtrl,
                        decoration: const InputDecoration(
                          labelText: "Dosage",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: instructionsCtrl,
                        maxLines: 3,
                        validator: (v) =>
                        v == null || v.isEmpty ? "Instructions required" : null,
                        decoration: const InputDecoration(
                          labelText: "Instructions",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // TIMES
                      Column(
                        children: [
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
                            ElevatedButton.icon(
                              onPressed: addTime,
                              icon: const Icon(Icons.add),
                              label: const Text("Add Time"),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // START DATE
                      ListTile(
                        title: Text(
                          startDate == null
                              ? "Select Start Date"
                              : DateFormat('yyyy-MM-dd').format(startDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(true),
                      ),

                      // END DATE
                      ListTile(
                        title: Text(
                          endDate == null
                              ? "Select End Date (optional)"
                              : DateFormat('yyyy-MM-dd').format(endDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(false),
                      ),

                      const SizedBox(height: 20),

                      // REPEAT OPTIONS
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Repeat",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),

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

                          if (repeatMode == "Custom")
                            Wrap(
                              spacing: 8,
                              children: weekDays.map((day) {
                                final selected =
                                selectedDays.contains(day);

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
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submitMedicine,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Save Medicine"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: goToNextPage,
                      child: const Text("Next"),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
