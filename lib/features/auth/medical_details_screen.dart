import 'package:flutter/material.dart';
//import 'package:dio/dio.dart';

import 'medicine_reminders_screen.dart';
import 'doctor_service.dart';
import '../../../core/network/dio_client.dart';
import 'theme.dart';

class MedicalDetailsScreen extends StatefulWidget {
  final int elderId;

  const MedicalDetailsScreen({super.key, required this.elderId});

  @override
  State<MedicalDetailsScreen> createState() => _MedicalDetailsScreenState();
}

class _MedicalDetailsScreenState extends State<MedicalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  String? bloodType;

  final allergiesCtrl = TextEditingController();
  final chronicCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final surgeriesCtrl = TextEditingController();
  final preferredDoctorCtrl = TextEditingController();

  DoctorItem? selectedDoctor;

  bool loading = false;
  bool submitted = false;

  final List<String> bloodTypes = const [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
    "Unknown"
  ];

  @override
  void dispose() {
    allergiesCtrl.dispose();
    chronicCtrl.dispose();
    notesCtrl.dispose();
    surgeriesCtrl.dispose();
    preferredDoctorCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint, {Widget? suffix, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.descriptionText,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.containerBackground,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.textShade.withValues(alpha: 0.30),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _stepDots() {
    const int total = 6;
    const int active = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i < active;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColors.primaryText
                : AppColors.textShade.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }

  String? _allergyValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z\s,.!]+$').hasMatch(t)) {
      return "Only letters and , . ! are allowed";
    }
    if (t.length > 120) return "Too long";
    return null;
  }

  String? _chronicValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z0-9\s,]+$').hasMatch(t)) {
      return "No symbols allowed";
    }
    if (t.length > 140) return "Too long";
    return null;
  }

  String? _notesValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z0-9\s,.!]+$').hasMatch(t)) {
      return "Only letters, numbers and , . ! are allowed";
    }
    if (t.length > 200) return "Too long";
    return null;
  }

  String? _surgeryValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z0-9\s,]+$').hasMatch(t)) {
      return "No symbols allowed";
    }
    if (t.length > 200) return "Too long";
    return null;
  }

  Future<void> _openDoctorSearch() async {
    FocusScope.of(context).unfocus();

    final picked = await showSearch<DoctorItem?>(
      context: context,
      delegate: DoctorSearchDelegate(),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        selectedDoctor = picked;
        preferredDoctorCtrl.text = picked.fullName;
      });
    }
  }

  Future<void> _submitMedicalDetailsToApi() async {
    final dio = DioClient.dio;

    final payload = {
      "elder_id": widget.elderId,
      "blood_type": bloodType ?? "",
      "allergies": allergiesCtrl.text.trim(),
      "chronic_conditions": chronicCtrl.text.trim(),
      "emergency_notes": notesCtrl.text.trim(),
      "past_surgeries": surgeriesCtrl.text.trim(),
      "preferred_doctor_id": selectedDoctor?.doctorId ?? 0,
    };

    final res = await dio.post(
      "/api/v1/caregiver/elder-create/elder-profile",
      data: payload,
    );

    final ok =
        res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;

    if (!ok) {
      throw Exception("Failed");
    }
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    setState(() {
      submitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedDoctor == null) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() => loading = true);

    try {
      await _submitMedicalDetailsToApi();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineRemindersScreen(elderId: widget.elderId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Medical Details",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.sectionBackground.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.textShade.withValues(alpha: 0.20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          _fieldCard(
                            child: DropdownButtonFormField<String>(
                              initialValue: bloodType,
                              items: bloodTypes
                                  .map(
                                    (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    b,
                                    style: const TextStyle(
                                      color: AppColors.primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                              onChanged: (v) => setState(() => bloodType = v),
                              decoration: _decor(
                                "Blood Type",
                                prefix: const Icon(Icons.bloodtype_outlined),
                              ),
                              validator: (v) =>
                              v == null ? "Please select blood type" : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldCard(
                            child: TextFormField(
                              controller: allergiesCtrl,
                              decoration: _decor(
                                "Allergies",
                                prefix:
                                const Icon(Icons.warning_amber_outlined),
                              ),
                              validator: _allergyValidator,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldCard(
                            child: TextFormField(
                              controller: chronicCtrl,
                              decoration: _decor(
                                "Chronic Conditions",
                                prefix: const Icon(Icons.healing_outlined),
                              ),
                              validator: _chronicValidator,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldCard(
                            child: TextFormField(
                              controller: notesCtrl,
                              maxLines: 2,
                              decoration: _decor(
                                "Emergency Notes",
                                prefix: const Icon(Icons.note_alt_outlined),
                              ),
                              validator: _notesValidator,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldCard(
                            child: TextFormField(
                              controller: surgeriesCtrl,
                              maxLines: 2,
                              decoration: _decor(
                                "Past Surgeries",
                                prefix:
                                const Icon(Icons.local_hospital_outlined),
                              ),
                              validator: _surgeryValidator,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldCard(
                            child: TextFormField(
                              controller: preferredDoctorCtrl,
                              readOnly: true,
                              onTap: _openDoctorSearch,
                              decoration: _decor(
                                "Preferred Doctor",
                                prefix: const Icon(
                                    Icons.medical_services_outlined),
                                suffix: const Icon(Icons.search),
                              ),
                              validator: (v) {
                                if (selectedDoctor == null) {
                                  return "Please select a doctor";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: loading ? null : _continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.8),
                                disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : const Text(
                                "Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _stepDots(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorSearchDelegate extends SearchDelegate<DoctorItem?> {
  @override
  String get searchFieldLabel => "Search Doctor";

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.containerBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x55FFFFFF),
        selectionHandleColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontWeight: FontWeight.w500,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = "",
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    return _DoctorResults(
      query: query,
      onPick: (doctor) => close(context, doctor),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _DoctorResults(
      query: query,
      onPick: (doctor) => close(context, doctor),
    );
  }
}

class _DoctorResults extends StatelessWidget {
  final String query;
  final void Function(DoctorItem doctor) onPick;

  const _DoctorResults({
    required this.query,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final q = query.trim();

    if (q.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Start typing a doctor's name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Search results will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryText.withValues(alpha: 0.65),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<List<DoctorItem>>(
      future: DoctorService.searchDoctors(
        doctorName: q,
        hospital: "",
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Something went wrong.\n${snap.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final list = snap.data ?? [];

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.containerBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.descriptionText.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  "No doctors found for \"$q\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryText.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final d = list[i];
            final spec = d.specialization.trim().isEmpty
                ? "Doctor"
                : d.specialization.trim();
            final hospital = d.hospital.trim();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.containerBackground,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onPick(d),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                        AppColors.descriptionText.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: AppColors.primary.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.fullName,
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _chip(spec, true),
                                  if (hospital.isNotEmpty) _chip(hospital, false),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primaryText.withValues(alpha: 0.55),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip(String text, bool primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.descriptionText.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primary ? AppColors.primary : AppColors.primaryText,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}