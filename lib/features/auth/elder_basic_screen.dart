import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
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
  final addressCtrl = TextEditingController();
  final relationCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool submitted = false;

  String? selectedGender;
  String? emailError;

  final List<String> genderOptions = const ["Male", "Female"];

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    relationCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decor(
      String hint, {
        Widget? suffix,
        Widget? prefix,
        String? error,
      }) {
    return InputDecoration(
      hintText: hint,
      errorText: error,
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
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ),
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

  Widget _fieldContainer({required Widget child}) {
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
    const int active = 2;

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

  String? _nameValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Full name is required";

    final regex = RegExp(r"^[A-Za-z\s]+$");

    if (!regex.hasMatch(t)) {
      return "Name must contain letters only";
    }

    if (t.length < 3) return "Name is too short";

    return null;
  }

  String? _emailValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Email is required";

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!regex.hasMatch(t)) {
      return "Enter a valid email";
    }

    if (emailError != null) {
      return emailError;
    }

    return null;
  }

  String? _phoneValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Phone number is required";

    if (!RegExp(r'^\d{10}$').hasMatch(t)) {
      return "Phone number must be exactly 10 digits";
    }

    return null;
  }

  String? _passwordValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Password is required";

    if (t.length < 6) return "Minimum 6 characters";

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(t);
    final hasNumber = RegExp(r'\d').hasMatch(t);

    if (!hasLetter || !hasNumber) {
      return "Use letters and numbers";
    }

    return null;
  }

  String? _addressValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Address is required";

    if (t.length < 12) {
      return "Please enter a full address";
    }

    if (t.length > 160) {
      return "Address is too long";
    }

    return null;
  }

  String? _relationshipValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Relationship is required";

    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(t)) {
      return "Only letters allowed";
    }

    return null;
  }

  String? _dobValidator(String? v) {
    final t = v?.trim() ?? "";

    if (t.isEmpty) return "Date of Birth is required";

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(t)) {
      return "Use format YYYY-MM-DD";
    }

    return null;
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1960),
      firstDate: DateTime(1900),
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
              backgroundColor: AppColors.containerBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final yyyy = picked.year.toString().padLeft(4, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');

      setState(() {
        dobCtrl.text = "$yyyy-$mm-$dd";
      });
    }
  }

  bool _looksLikeExistingAccountError(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final data = e.response?.data?.toString().toLowerCase() ?? "";
      final msg = e.message?.toLowerCase() ?? "";

      if (code == 409) return true;

      if (code == 400 || code == 401 || code == 403 || code == 422) {
        if (data.contains("already") ||
            data.contains("exists") ||
            data.contains("duplicate") ||
            data.contains("email") ||
            data.contains("request denied") ||
            data.contains("request failed") ||
            data.contains("failed to register elder")) {
          return true;
        }
      }

      if (msg.contains("request failed") ||
          msg.contains("request denied") ||
          msg.contains("failed to register elder")) {
        return true;
      }
    }

    final msg = e.toString().toLowerCase();

    return msg.contains("already") ||
        msg.contains("exists") ||
        msg.contains("duplicate") ||
        msg.contains("email already") ||
        msg.contains("account already") ||
        msg.contains("existing") ||
        msg.contains("request denied") ||
        msg.contains("request failed") ||
        msg.contains("failed to register elder");
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      submitted = true;
      emailError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedGender == null) {
      return;
    }

    setState(() => loading = true);

    try {
      final caregiverId = await SessionManager.getUserId();

      final data = await AuthService.createElder(
        fullName: fullNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        dateOfBirth: dobCtrl.text.trim(),
        gender: selectedGender!,
        address: addressCtrl.text.trim(),
        caregiverId: caregiverId!,
        relationshipType: relationCtrl.text.trim(),
        isPrimary: true,
      );

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
    } on DioException catch (e) {
      if (_looksLikeExistingAccountError(e)) {
        setState(() {
          emailError = "Account already exists. Log in or use another email";
          loading = false;
        });
        _formKey.currentState?.validate();
        return;
      }

      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (e.response?.data is Map && e.response?.data["detail"] != null)
                ? e.response!.data["detail"].toString()
                : "Request failed",
          ),
        ),
      );
    } catch (e) {
      if (_looksLikeExistingAccountError(e)) {
        setState(() {
          emailError = "Account already exists. Log in or use another email";
          loading = false;
        });
        _formKey.currentState?.validate();
        return;
      }

      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
        ),
      );
    }
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
          "Elder Details",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                    _fieldContainer(
                      child: TextFormField(
                        controller: fullNameCtrl,
                        decoration: _decor(
                          "Full Name",
                          prefix: const Icon(Icons.person_outline),
                        ),
                        validator: _nameValidator,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: TextFormField(
                        controller: emailCtrl,
                        decoration: _decor(
                          "Email",
                          prefix: const Icon(Icons.mail_outline),
                          error: emailError,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (emailError != null) {
                            setState(() => emailError = null);
                          }
                        },
                        validator: _emailValidator,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: _decor(
                          "Phone",
                          prefix: const Icon(Icons.phone_outlined),
                        ),
                        validator: _phoneValidator,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: TextFormField(
                        controller: passwordCtrl,
                        obscureText: !showPassword,
                        decoration: _decor(
                          "Password",
                          prefix: const Icon(Icons.lock_outline),
                          suffix: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textShade,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        validator: _passwordValidator,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: TextFormField(
                        controller: dobCtrl,
                        readOnly: true,
                        onTap: _pickDob,
                        decoration: _decor(
                          "Date of Birth (YYYY-MM-DD)",
                          prefix: const Icon(Icons.calendar_month_outlined),
                        ),
                        validator: _dobValidator,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedGender,
                        items: genderOptions
                            .map(
                              (g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ),
                        )
                            .toList(),
                        onChanged: (v) => setState(() => selectedGender = v),
                        decoration: _decor(
                          "Select Gender",
                          prefix: const Icon(Icons.person),
                        ),
                        validator: (v) =>
                        v == null ? "Gender is required" : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: TextFormField(
                        controller: addressCtrl,
                        maxLines: 2,
                        decoration: _decor(
                          "Address",
                          prefix: const Icon(Icons.location_on_outlined),
                        ),
                        validator: _addressValidator,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldContainer(
                      child: TextFormField(
                        controller: relationCtrl,
                        decoration: _decor(
                          "Relationship (ex: Mother, Father etc.)",
                          prefix: const Icon(Icons.family_restroom),
                        ),
                        validator: _relationshipValidator,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: loading ? null : submit,
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
                          color: Colors.white,
                        )
                            : const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }
}