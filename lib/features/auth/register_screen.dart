import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
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
  bool submitted = false;

  String? emailServerError;

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
        String? errorText,
      }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      hintStyle: const TextStyle(
        color: AppColors.descriptionText,
        fontWeight: FontWeight.w500,
        fontSize: 15.5,
      ),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
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
          width: 1.6,
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
          width: 1.6,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12.2,
        fontWeight: FontWeight.w600,
      ),
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
    if (emailServerError != null) return emailServerError;
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

  bool _looksLikeExistingAccountError(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final data = e.response?.data?.toString().toLowerCase() ?? "";
      final msg = e.message?.toLowerCase() ?? "";

      if (code == 409) return true;

      if (code == 400 || code == 422) {
        if (data.contains("already") ||
            data.contains("exists") ||
            data.contains("duplicate") ||
            data.contains("email")) {
          return true;
        }
      }

      if (msg.contains("request failed") &&
          (data.contains("already") ||
              data.contains("exists") ||
              data.contains("duplicate") ||
              data.contains("email"))) {
        return true;
      }
    }

    final msg = e.toString().toLowerCase();
    return msg.contains("already") ||
        msg.contains("exists") ||
        msg.contains("duplicate") ||
        msg.contains("email already") ||
        msg.contains("account already") ||
        msg.contains("request denied") ||
        msg.contains("request failed");
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    setState(() {
      submitted = true;
      emailServerError = null;
    });

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (gender == null || gender!.trim().isEmpty) {
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
    } on DioException catch (e) {
      if (_looksLikeExistingAccountError(e)) {
        setState(() {
          emailServerError =
          "Account already exists. Log in or use another email";
          loading = false;
        });
        _formKey.currentState?.validate();
        return;
      }

      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            (e.response?.data is Map && e.response?.data["detail"] != null)
                ? e.response!.data["detail"].toString()
                : "Request failed",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (_looksLikeExistingAccountError(e)) {
        setState(() {
          emailServerError =
          "Account already exists. Log in or use another email";
          loading = false;
        });
        _formKey.currentState?.validate();
        return;
      }

      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildTopIcon() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(
          color: AppColors.sectionSeparator.withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 46,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 26),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.sectionBackground.withValues(alpha: 0.30),
                    border: Border.all(
                      color: AppColors.textShade.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTopIcon(),
                        const SizedBox(height: 12),
                        const Text(
                          "Let’s set up your profile",
                          style: TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
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
                            fontSize: 15.5,
                          ),
                          validator: _nameValidator,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
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
                            fontSize: 15.5,
                          ),
                          validator: _phoneValidator,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (emailServerError != null) {
                              setState(() => emailServerError = null);
                            }
                          },
                          decoration: _decor(
                            "Email",
                            prefix: const Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.textShade,
                            ),
                            errorText: emailServerError,
                          ),
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                          ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
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
                            fontSize: 15.5,
                          ),
                          validator: _dobValidator,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
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
                            fontSize: 15.5,
                          ),
                          validator: _addressValidator,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
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
                                  fontSize: 15.5,
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
                        const SizedBox(height: 12),

                        TextFormField(
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
                            fontSize: 15.5,
                          ),
                          validator: _passwordValidator,
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
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
                              elevation: 0,
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
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        _stepDots(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}