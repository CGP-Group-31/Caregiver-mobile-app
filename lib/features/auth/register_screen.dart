import 'package:flutter/material.dart';
import '../../../core/session/session_manager.dart';
import 'auth_service.dart';
import 'elder_basic_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ---- Color palette (NOT using last 3 colors) ----
  static const Color cPrimary = Color(0xFF2E7D7A); // teal
  static const Color cBg = Color(0xFFD6EFE6); // light mint background
  static const Color cMint = Color(0xFFBEE8DA); // mint
  static const Color cSurface = Color(0xFFF6F7F3); // off white
  static const Color cTextDark = Color(0xFF243333); // dark
  static const Color cGrey1 = Color(0xFF6F7F7D); // grey
  static const Color cGrey2 = Color(0xFF7C8B89); // grey

  final _formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String? gender; // dropdown selected value

  bool loading = false;
  bool showPassword = false;

  final List<String> genders = const ["Male", "Female", "Other", "Prefer not to say"];

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  // ---------- UI helpers ----------
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
    // Wireframe shows multiple dots; caregiver profile setup is step 1.
    const int total = 7;
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
            color: filled ? cTextDark : cGrey2.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }

  // ---------- Validation helpers ----------
  String? _nameValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Full name is required";
    if (value.length < 2) return "Name is too short";
    if (!RegExp(r"^[a-zA-Z\s\.\-']+$").hasMatch(value)) {
      return "Name contains invalid characters";
    }
    return null;
  }

  String? _emailValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Email is required";
    if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _phoneValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Mobile number is required";

    // allow +, spaces, and digits, but validate digit count
    final digits = value.replaceAll(RegExp(r"\D"), "");
    if (digits.length < 9 || digits.length > 15) {
      return "Enter a valid mobile number";
    }
    return null;
  }

  String? _dobValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Date of birth is required";

    // Expect YYYY-MM-DD
    if (!RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(value)) {
      return "Use format YYYY-MM-DD";
    }

    try {
      final parts = value.split("-");
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);

      final dt = DateTime(y, m, d);
      // DateTime auto-corrects invalid dates; check match:
      if (dt.year != y || dt.month != m || dt.day != d) {
        return "Invalid date";
      }

      final now = DateTime.now();
      if (dt.isAfter(now)) return "DOB cannot be in the future";

      // Optional: require at least 10 years old (feel free to remove)
      final age = now.year - dt.year - ((now.month < dt.month || (now.month == dt.month && now.day < dt.day)) ? 1 : 0);
      if (age < 10) return "Age seems too low";
    } catch (_) {
      return "Invalid date";
    }

    return null;
  }

  String? _addressValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Address is required";
    if (value.length < 5) return "Address is too short";
    if (value.length > 120) return "Address is too long (max 120 chars)";
    return null;
  }

  String? _passwordValidator(String? v) {
    final value = (v ?? "");
    if (value.trim().isEmpty) return "Password is required";
    if (value.length < 6) return "Minimum 6 characters";
    if (!RegExp(r"[A-Za-z]").hasMatch(value) || !RegExp(r"\d").hasMatch(value)) {
      return "Use letters and numbers";
    }
    return null;
  }

  // ---------- Date picker ----------
  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();

    DateTime initial = DateTime(1990, 1, 1);
    try {
      if (dobCtrl.text.trim().isNotEmpty) {
        final parts = dobCtrl.text.trim().split("-");
        if (parts.length == 3) {
          initial = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: cPrimary,
              onPrimary: Colors.white,
              onSurface: cTextDark,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: cSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final yyyy = picked.year.toString().padLeft(4, "0");
      final mm = picked.month.toString().padLeft(2, "0");
      final dd = picked.day.toString().padLeft(2, "0");
      setState(() => dobCtrl.text = "$yyyy-$mm-$dd");
    }
  }

  // ---------- Register action ----------
  Future<void> register() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // validate gender separately (dropdown validator can handle too, but we keep safe)
    if (gender == null || gender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final userId = await AuthService.registerCaregiver(
        fullName: fullNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        dateOfBirth: dobCtrl.text.trim(), // YYYY-MM-DD
        gender: gender!.trim(),
        address: addressCtrl.text.trim(),
      );

      await SessionManager.saveUser(userId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ElderBasicScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
          "Caregiver Profile Setup",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cMint.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cGrey2.withValues(alpha: 0.18)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ---- Avatar placeholder with camera icon (wireframe style) ----
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: cSurface,
                          child: Icon(Icons.person_rounded, size: 56, color: cGrey2.withValues(alpha: 0.75)),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cPrimary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ---- Full Name ----
                    TextFormField(
                      controller: fullNameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decor("Full Name"),
                      style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                      validator: _nameValidator,
                    ),
                    const SizedBox(height: 12),

                    // ---- Mobile ----
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: _decor("Mobile"),
                      style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 12),

                    // ---- Email ----
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _decor("Email"),
                      style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),

                    // ---- DOB (date picker, saved as YYYY-MM-DD) ----
                    TextFormField(
                      controller: dobCtrl,
                      readOnly: true,
                      onTap: _pickDob,
                      decoration: _decor(
                        "DOB (YYYY-MM-DD)",
                        suffix: IconButton(
                          onPressed: _pickDob,
                          icon: const Icon(Icons.chevron_right_rounded, color: cGrey2),
                        ),
                      ),
                      style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                      validator: _dobValidator,
                    ),
                    const SizedBox(height: 12),

                    // ---- Address ----
                    TextFormField(
                      controller: addressCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _decor("Address"),
                      style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                      validator: _addressValidator,
                    ),
                    const SizedBox(height: 12),

                    // ---- Gender dropdown ----
                    DropdownButtonFormField<String>(
                      initialValue: gender,
                      items: genders
                          .map(
                            (g) => DropdownMenuItem<String>(
                          value: g,
                          child: Text(
                            g,
                            style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => gender = v),
                      decoration: _decor(
                        "Select Gender",
                        suffix: const Icon(Icons.chevron_right_rounded, color: cGrey2),
                      ),
                      dropdownColor: cSurface,
                      validator: (v) => (v == null || v.isEmpty) ? "Please select a gender" : null,
                    ),
                    const SizedBox(height: 12),

                    // ---- Password with show/hide ----
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: !showPassword,
                      textInputAction: TextInputAction.done,
                      decoration: _decor(
                        "Password",
                        suffix: IconButton(
                          onPressed: () => setState(() => showPassword = !showPassword),
                          icon: Icon(
                            showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: cGrey2,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: cTextDark, fontWeight: FontWeight.w600),
                      validator: _passwordValidator,
                    ),

                    const SizedBox(height: 18),

                    // ---- Continue button ----
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
      ),
    );
  }
}
