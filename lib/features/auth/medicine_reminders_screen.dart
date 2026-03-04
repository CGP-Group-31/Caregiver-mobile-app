import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/session/session_manager.dart';
import 'medicine_service.dart';
import 'emergency_contacts_page.dart';
import 'theme.dart';

class MedicineRemindersScreen extends StatefulWidget {
  final int elderId;
  const MedicineRemindersScreen({super.key, required this.elderId});

  @override
  State<MedicineRemindersScreen> createState() => _MedicineRemindersScreenState();
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

  final List<String> weekDays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];

  Future<void> addTime() async {
    if (selectedTimes.length >= 6) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
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
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

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

  String buildRepeatString() {
    if (repeatMode == "Daily") return "Daily";
    if (repeatMode == "EveryOtherDay") return "EveryOtherDay";

    final order = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
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

      final startDateFormatted = DateFormat('yyyy-MM-dd').format(startDate!);

      final endDateFormatted = endDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(endDate!);

      await MedicineService.createMedicine(
        elderId: widget.elderId,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => loading = false);
  }

  void goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyContactsPage(elderId: widget.elderId),
      ),
    );
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
            letterSpacing: 0.5,
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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0,6),
                      )
                    ],
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
                          v == null || v.isEmpty
                              ? "Instructions required"
                              : null,
                        ),

                        const SizedBox(height: 30),

                        _sectionTitle("Reminder Times"),

                        const SizedBox(height: 10),

                        ...selectedTimes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final time = entry.value;
                          final formatted =
                              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.sectionBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.access_time,
                                  color: AppColors.primary),
                              title: Text(
                                formatted,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: AppColors.sosButton),
                                onPressed: () => removeTime(index),
                              ),
                            ),
                          );
                        }),

                        if (selectedTimes.length < 6)
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 12),
                              ),
                              onPressed: addTime,
                              icon: const Icon(Icons.add,
                                  color: Colors.white),
                              label: const Text(
                                "Add Time",
                                style:
                                TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),

                        _sectionTitle("Duration"),

                        _buildDateTile(
                          title: startDate == null
                              ? "Select Start Date"
                              : DateFormat('yyyy-MM-dd')
                              .format(startDate!),
                          onTap: () => pickDate(true),
                        ),

                        const SizedBox(height: 10),

                        _buildDateTile(
                          title: endDate == null
                              ? "Select End Date (optional)"
                              : DateFormat('yyyy-MM-dd')
                              .format(endDate!),
                          onTap: () => pickDate(false),
                        ),

                        const SizedBox(height: 30),

                        _sectionTitle("Repeat"),

                        RadioListTile(
                          activeColor: AppColors.primary,
                          title: const Text("Daily"),
                          value: "Daily",
                          groupValue: repeatMode,
                          onChanged: (v) =>
                              setState(() => repeatMode = v!),
                        ),
                        RadioListTile(
                          activeColor: AppColors.primary,
                          title: const Text("Every Other Day"),
                          value: "EveryOtherDay",
                          groupValue: repeatMode,
                          onChanged: (v) =>
                              setState(() => repeatMode = v!),
                        ),
                        RadioListTile(
                          activeColor: AppColors.primary,
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
                                selectedColor:
                                AppColors.primary,
                                backgroundColor:
                                AppColors.sectionBackground,
                                label: Text(
                                  day,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.primaryText,
                                  ),
                                ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: loading ? null : submitMedicine,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Save Medicine",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: goToNextPage,
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
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
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textShade),
        filled: true,
        fillColor: AppColors.sectionBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }
}