import 'package:flutter/material.dart';
import 'medicine_reminders_screen.dart';

class MedicalDetailsScreen extends StatefulWidget {
  const MedicalDetailsScreen({super.key});

  @override
  State<MedicalDetailsScreen> createState() => _MedicalDetailsScreenState();
}

class _MedicalDetailsScreenState extends State<MedicalDetailsScreen> {
  // ---- Color palette (NOT using last 3 colors) ----
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

  InputDecoration _decor(String hint, {bool showArrow = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: cGrey1, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: cSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: showArrow
          ? const Icon(Icons.chevron_right_rounded, color: cGrey2)
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cGrey2.withOpacity(0.35), width: 1),
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
    // medical details is step 2 in your wireframe dots example
    // We'll show 6 dots with first 2 filled.
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
            color: filled ? cTextDark : cGrey2.withOpacity(0.35),
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

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => loading = true);

    // Front-end only for now
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicineRemindersScreen()),
    );

    setState(() => loading = false);
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
                      color: cMint.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cGrey2.withOpacity(0.18)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: bloodType,
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
                            decoration: _decor("Blood Type...", showArrow: true),
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
                            decoration:
                            _decor("Preferred Doctor", showArrow: true),
                            style: const TextStyle(
                              color: cTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) =>
                                _optionalMax(v, 80, "Preferred Doctor"),
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

