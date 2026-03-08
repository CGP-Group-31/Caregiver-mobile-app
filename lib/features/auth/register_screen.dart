import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/session/session_manager.dart';
import 'theme.dart';
import 'auth_service.dart';
import 'elder_basic_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String? gender;

  bool loading = false;
  bool showPassword = false;

  final List<String> genders = const ["Male", "Female"];

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

  InputDecoration _decor(
      String hint, {
        Widget? suffix,
        Widget? prefix,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.descriptionText,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.textShade.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.7,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _stepDots() {
    const int total = 7;
    const int active = 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i < active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: filled ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: filled
                ? AppColors.primaryText
                : AppColors.textShade.withValues(alpha: 0.28),
          ),
        );
      }),
    );
  }

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
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "Mobile number must contain digits only";
    }
    if (value.length != 10) {
      return "Mobile number must be exactly 10 digits";
    }

    return null;
  }

  String? _dobValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Date of birth is required";

    if (!RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(value)) {
      return "Use format YYYY-MM-DD";
    }

    try {
      final parts = value.split("-");
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);

      final dt = DateTime(y, m, d);
      if (dt.year != y || dt.month != m || dt.day != d) {
        return "Invalid date";
      }

      final now = DateTime.now();
      if (dt.isAfter(now)) return "DOB cannot be in the future";

      final age = now.year -
          dt.year -
          ((now.month < dt.month ||
              (now.month == dt.month && now.day < dt.day))
              ? 1
              : 0);

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
    if (!RegExp(r"[A-Za-z]").hasMatch(value) ||
        !RegExp(r"\d").hasMatch(value)) {
      return "Use letters and numbers";
    }
    return null;
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();

    DateTime initial = DateTime(1990, 1, 1);
    try {
      if (dobCtrl.text.trim().isNotEmpty) {
        final parts = dobCtrl.text.trim().split("-");
        if (parts.length == 3) {
          initial = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.background,
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

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

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
        dateOfBirth: dobCtrl.text.trim(),
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  Widget _buildTopIcon() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.90),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(
          color: AppColors.sectionSeparator.withValues(alpha: 0.65),
          width: 1.4,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 56,
        color: AppColors.textShade.withValues(alpha: 0.75),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Caregiver Profile Setup",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 21,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.sectionBackground.withValues(alpha: 0.42),
                    AppColors.sectionBackground.withValues(alpha: 0.25),
                  ],
                ),
                border: Border.all(
                  color: AppColors.textShade.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    _buildTopIcon(),
                    const SizedBox(height: 12),
                    const Text(
                      "Let’s set up your profile",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Please enter your details to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.descriptionText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildFieldContainer(
                      child: TextFormField(
                        controller: fullNameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _decor(
                          "Full Name",
                          prefix: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.textShade,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: _nameValidator,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldContainer(
                      child: TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: _decor(
                          "Mobile",
                          prefix: const Icon(
                            Icons.phone_outlined,
                            color: AppColors.textShade,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: _phoneValidator,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldContainer(
                      child: TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _decor(
                          "Email",
                          prefix: const Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.textShade,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: _emailValidator,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldContainer(
                      child: TextFormField(
                        controller: dobCtrl,
                        readOnly: true,
                        onTap: _pickDob,
                        decoration: _decor(
                          "DOB (YYYY-MM-DD)",
                          prefix: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.textShade,
                          ),
                          suffix: IconButton(
                            onPressed: _pickDob,
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textShade,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: _dobValidator,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldContainer(
                      child: TextFormField(
                        controller: addressCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _decor(
                          "Address",
                          prefix: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textShade,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: _addressValidator,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldContainer(
                      child: DropdownButtonFormField<String>(
                        initialValue: gender,
                        items: genders
                            .map(
                              (g) => DropdownMenuItem<String>(
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
                        onChanged: (v) => setState(() => gender = v),
                        decoration: _decor(
                          "Select Gender",
                          prefix: const Icon(
                            Icons.wc_rounded,
                            color: AppColors.textShade,
                          ),
                          suffix: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textShade,
                          ),
                        ),
                        dropdownColor: AppColors.background,
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Please select a gender"
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldContainer(
                      child: TextFormField(
                        controller: passwordCtrl,
                        obscureText: !showPassword,
                        textInputAction: TextInputAction.done,
                        decoration: _decor(
                          "Password",
                          prefix: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textShade,
                          ),
                          suffix: IconButton(
                            onPressed: () {
                              setState(() => showPassword = !showPassword);
                            },
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textShade,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: _passwordValidator,
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 4,
                          shadowColor:
                          AppColors.primary.withValues(alpha: 0.30),
                        ),
                        child: loading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
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

                    const SizedBox(height: 18),
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