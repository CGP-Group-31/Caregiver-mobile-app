import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import 'theme.dart';
import 'auth_service.dart';
import 'medical_details_screen.dart';

class ElderBasicScreen extends StatefulWidget {
  const ElderBasicScreen({super.key});

  @override
  State<ElderBasicScreen> createState() => _ElderBasicScreenState();
}

class _ElderBasicScreenState extends State<ElderBasicScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final relationCtrl = TextEditingController();

  bool loading = false;

  // Dropdown values
  final List<String> genderOptions = const ["Male", "Female", "Other"];

  String? selectedGender;

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    dobCtrl.dispose();
    genderCtrl.dispose();
    addressCtrl.dispose();
    relationCtrl.dispose();
    super.dispose();
  }

  // --- Input Decoration (matches MedicalDetails styling) ---
  InputDecoration _decor(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.descriptionText,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.containerBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.textShade.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
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
    // Elder basic is step 1 (show first dot filled)
    const int total = 6;
    const int active = 1;

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

  String? _requiredText(String? v, String name, {int max = 120}) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return "$name is required";
    if (t.length > max) return "$name is too long (max $max chars)";
    return null;
  }

  String? _emailValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(t)) return "Enter a valid email";
    if (t.length > 120) return "Email is too long";
    return null;
  }

  String? _phoneValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Phone number is required";

    // Only digits allowed
    final digitsOnly = RegExp(r'^\d{10}$');

    if (!digitsOnly.hasMatch(t)) {
      return "Phone number must be exactly 10 digits";
    }

    return null;
  }

  String? _passwordValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Password is required";
    if (t.length < 6) return "Password must be at least 6 characters";
    if (t.length > 64) return "Password is too long";

    // Must contain at least one letter and one number
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(t);
    final hasNumber = RegExp(r'[0-9]').hasMatch(t);

    if (!hasLetter || !hasNumber) {
      return "Password must contain letters and numbers";
    }

    return null;
  }

  String? _relationshipValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return "Relationship is required";

    // Only letters and spaces allowed
    final regex = RegExp(r'^[A-Za-z\s]+$');
    if (!regex.hasMatch(t)) {
      return "Only letters allowed (no numbers or symbols)";
    }

    if (t.length > 40) return "Relationship is too long";

    return null;
  }

  String? _dobValidator(String? v) {
    final t = v?.trim() ?? "";
    if (t.isEmpty) return "Date of Birth is required";
    // Expect YYYY-MM-DD (same as backend expectation)
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(t)) return "Use format YYYY-MM-DD";
    return null;
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final firstDate = DateTime(1900, 1, 1);
    final initial = DateTime(now.year - 60, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.containerBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (picked == null) return;

    final yyyy = picked.year.toString().padLeft(4, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final dd = picked.day.toString().padLeft(2, '0');

    setState(() {
      dobCtrl.text = "$yyyy-$mm-$dd";
    });
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    // Ensure dropdowns selected
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select gender")),
      );
      return;
    }


    setState(() => loading = true);

    try {
      final caregiverId = await SessionManager.getUserId();

      if (!mounted) return;

      if (caregiverId == null) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Caregiver ID not found. Please login.")),
        );
        return;
      }

      final data = await AuthService.createElder(
        fullName: fullNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        dateOfBirth: dobCtrl.text.trim(),
        gender: selectedGender!,
        address: addressCtrl.text.trim(),
        caregiverId: caregiverId,
        relationshipType: relationCtrl.text.trim(),
        isPrimary: true,
      );

      if (!mounted) return;

      final elderId = data["user_id"];
      final relationshipId = data["relationship_id"];

      await SessionManager.saveElderData(elderId, relationshipId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicalDetailsScreen(elderId: elderId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Elder Details",
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
                      color: AppColors.sectionBackground.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.textShade.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: fullNameCtrl,
                            decoration: _decor("Full Name"),
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) => _requiredText(v, "Full name",
                                max: 80),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: emailCtrl,
                            decoration: _decor("Email"),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: _emailValidator,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: phoneCtrl,
                            decoration: _decor("Phone"),
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: _phoneValidator,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: passwordCtrl,
                            decoration: _decor(
                              "Password",
                              suffix: const Icon(Icons.lock_rounded,
                                  color: AppColors.textShade),
                            ),
                            obscureText: true,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: _passwordValidator,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          // DOB (picker)
                          TextFormField(
                            controller: dobCtrl,
                            readOnly: true,
                            onTap: _pickDob,
                            decoration: _decor(
                              "Date of Birth (YYYY-MM-DD)",
                              suffix: const Icon(Icons.calendar_month_rounded,
                                  color: AppColors.textShade),
                            ),
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: _dobValidator,
                          ),
                          const SizedBox(height: 12),

                          // Gender dropdown
                          DropdownButtonFormField<String>(
                            initialValue: selectedGender,
                            items: genderOptions
                                .map(
                                  (g) => DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => setState(() {
                              selectedGender = v;
                            }),
                            decoration: _decor(
                              "Select Gender",
                              suffix: const Icon(Icons.expand_more_rounded,
                                  color: AppColors.textShade),
                            ),
                            dropdownColor: AppColors.containerBackground,
                            validator: (v) =>
                            v == null ? "Gender is required" : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: addressCtrl,
                            decoration: _decor("Address"),
                            maxLines: 2,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (v) => _requiredText(v, "Address",
                                max: 160),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),

                          // Relationship text field
                          TextFormField(
                            controller: relationCtrl,
                            decoration: _decor("Relationship"),
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: _relationshipValidator,
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
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
                                "Next",
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