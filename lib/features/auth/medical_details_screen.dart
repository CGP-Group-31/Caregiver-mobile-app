import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'medicine_reminders_screen.dart';
import 'doctor_service.dart';
import '../../../core/network/dio_client.dart'; // adjust if your path differs

class MedicalDetailsScreen extends StatefulWidget {
  final int elderId;

  const MedicalDetailsScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<MedicalDetailsScreen> createState() => _MedicalDetailsScreenState();
}

class _MedicalDetailsScreenState extends State<MedicalDetailsScreen> {

  static const Color cPrimary = Color(0xFF2E7D7A); // teal
  static const Color cBg = Color(0xFFD6EFE6); // light mint background
  static const Color cMint = Color(0xFFBEE8DA); // mint
  static const Color cSurface = Color(0xFFF6F7F3); // off white
  static const Color cTextDark = Color(0xFF243333); // dark
  static const Color cGrey1 = Color(0xFF6F7F7D); // grey
  static const Color cGrey2 = Color(0xFF7C8B89); // grey

  final _formKey = GlobalKey<FormState>();

  String? bloodType;

  final allergiesCtrl = TextEditingController();
  final chronicCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final surgeriesCtrl = TextEditingController();


  final preferredDoctorCtrl = TextEditingController();
  DoctorItem? selectedDoctor;

  bool loading = false;

  final List<String> bloodTypes = const [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
    "Unknown",
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

  InputDecoration _decor(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: cGrey1, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: cSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cGrey2.withValues(alpha: 0.35), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cPrimary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }

  Widget _stepDots() {
    const int total = 6;
    const int active = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final bool filled = (i < active);
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? cTextDark : cGrey2.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }

  String? _optionalMax(String? v, int max, String fieldName) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (v.trim().length > max) return "$fieldName is too long (max $max chars)";
    return null;
  }

  Future<void> _openDoctorSearch() async {
    FocusScope.of(context).unfocus();

    final picked = await showSearch<DoctorItem?>(
      context: context,
      delegate: DoctorSearchDelegate(
        primary: cPrimary,
        surface: cSurface,
        textDark: cTextDark,
        grey1: cGrey1,
        grey2: cGrey2,
      ),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        selectedDoctor = picked;
        preferredDoctorCtrl.text = picked.fullName;
      });
    }
  }

  // API CALL
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

    try {

      final res = await dio.post(
        "/api/v1/caregiver/elder-create/elder-profile",
        data: payload,
      );

      // If backend returns 200/201 etc, treat as success
      final ok = res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
      if (!ok) {
        throw Exception("Failed with status: ${res.statusCode}");
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 422) {
        throw Exception("Please check the details you entered (validation error).");
      } else if (status == 404) {

        throw Exception(data is Map && data["detail"] != null
            ? data["detail"].toString()
            : "Resource not found.");
      } else if (status == 500) {
        throw Exception("Server error. Please try again.");
      } else {
        throw Exception(
          data is Map && data["detail"] != null ? data["detail"].toString() : "Something went wrong.",
        );
      }
    }
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor")),
      );
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
      backgroundColor: cBg,
      appBar: AppBar(
        backgroundColor: cPrimary,
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cMint.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cGrey2.withValues(alpha: 0.35)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: bloodType,
                            items: bloodTypes
                                .map(
                                  (b) => DropdownMenuItem(
                                value: b,
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    color: cTextDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => setState(() => bloodType = v),
                            decoration: _decor(
                              "Blood Type...",
                              suffix: const Icon(Icons.chevron_right_rounded,
                                  color: cGrey2),
                            ),
                            dropdownColor: cSurface,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Please select a blood type";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: allergiesCtrl,
                            decoration: _decor("Allergies..."),
                            style: const TextStyle(
                              color: cTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) => _optionalMax(v, 120, "Allergies"),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: chronicCtrl,
                            decoration: _decor("Chronic Conditions..."),
                            style: const TextStyle(
                              color: cTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) =>
                                _optionalMax(v, 140, "Chronic Conditions"),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: notesCtrl,
                            maxLines: 2,
                            decoration: _decor("Important Notes..."),
                            style: const TextStyle(
                              color: cTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) =>
                                _optionalMax(v, 200, "Important Notes"),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: surgeriesCtrl,
                            maxLines: 2,
                            decoration: _decor("Past Surgeries..."),
                            style: const TextStyle(
                              color: cTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) =>
                                _optionalMax(v, 200, "Past Surgeries"),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: preferredDoctorCtrl,
                            readOnly: true,
                            onTap: _openDoctorSearch,
                            decoration: _decor(
                              "Preferred Doctor",
                              suffix: const Icon(Icons.search_rounded,
                                  color: cGrey2),
                            ),
                            style: const TextStyle(
                              color: cTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) {
                              final err =
                              _optionalMax(v, 80, "Preferred Doctor");
                              if (err != null) return err;

                              if (selectedDoctor == null) {
                                return "Please select a doctor";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : _continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: loading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                "Continue",
                                style: TextStyle(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class DoctorSearchDelegate extends SearchDelegate<DoctorItem?> {
  DoctorSearchDelegate({
    required this.primary,
    required this.surface,
    required this.textDark,
    required this.grey1,
    required this.grey2,
  });

  final Color primary;
  final Color surface;
  final Color textDark;
  final Color grey1;
  final Color grey2;

  @override
  String get searchFieldLabel => "Search doctor name";

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x55FFFFFF),
        selectionHandleColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
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
    return _DoctorResultsNice(
      query: query,
      surface: surface,
      textDark: textDark,
      grey1: grey1,
      primary: primary,
      onPick: (d) => close(context, d),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _DoctorResultsNice(
      query: query,
      surface: surface,
      textDark: textDark,
      grey1: grey1,
      primary: primary,
      onPick: (d) => close(context, d),
    );
  }
}

class _DoctorResultsNice extends StatelessWidget {
  const _DoctorResultsNice({
    required this.query,
    required this.surface,
    required this.textDark,
    required this.grey1,
    required this.primary,
    required this.onPick,
  });

  final String query;
  final Color surface;
  final Color textDark;
  final Color grey1;
  final Color primary;
  final void Function(DoctorItem doctor) onPick;

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
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 40,
                  color: primary.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  "Start typing a doctor's name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Results will appear here as you type.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark.withValues(alpha: 0.65),
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
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: grey1.withValues(alpha: 0.2)),
                ),
                child: Text(
                  "No doctors found for \"$q\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark.withValues(alpha: 0.75),
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
                color: surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onPick(d),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: grey1.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: primary.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.fullName,
                                style: TextStyle(
                                  color: textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _chip(spec, isPrimary: true, textDark: textDark),
                                  if (hospital.isNotEmpty)
                                    _chip(hospital, isPrimary: false, textDark: textDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.chevron_right_rounded,
                            color: textDark.withValues(alpha: 0.55)),
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

  Widget _chip(String text, {required bool isPrimary, required Color textDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? primary.withValues(alpha: 0.12)
            : grey1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPrimary ? primary : textDark,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}