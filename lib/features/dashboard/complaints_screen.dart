import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/session/session_manager.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/theme.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _formKey = GlobalKey<FormState>();

  final subjectCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  bool loading = false;
  bool submitted = false;
  bool success = false;
  String? submitError;

  @override
  void dispose() {
    subjectCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint, {Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.descriptionText,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.containerBackground,
      prefixIcon: prefix,
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

  String? _subjectValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Subject is required";
    if (value.length < 3) return "Subject is too short";
    if (value.length > 255) return "Subject is too long";
    return null;
  }

  String? _descriptionValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Description is required";
    if (value.length < 10) return "Please describe the complaint more clearly";
    return null;
  }

  Future<void> _submitComplaint() async {
    FocusScope.of(context).unfocus();

    setState(() {
      submitted = true;
      submitError = null;
      success = false;
    });

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => loading = true);

    try {
      final userId = await SessionManager.getUserId();

      if (userId == null) {
        setState(() {
          loading = false;
          submitError = "Session expired. Please login again.";
        });
        return;
      }

      await DioClient.dio.post(
        "/api/v1/caregiver/complaints",
        data: {
          "complainant_id": userId,
          "subject": subjectCtrl.text.trim(),
          "description": descriptionCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      setState(() {
        loading = false;
        success = true;
      });

      subjectCtrl.clear();
      descriptionCtrl.clear();
    } on DioException catch (e) {
      String msg = "Failed to submit complaint";

      if (e.response?.data is Map && e.response?.data["detail"] != null) {
        msg = e.response!.data["detail"].toString();
      }

      setState(() {
        loading = false;
        submitError = msg;
      });
    } catch (_) {
      setState(() {
        loading = false;
        submitError = "Something went wrong. Please try again.";
      });
    }
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
          ),
        ],
      ),
      child: child,
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
        title: const Text(
          "Complaints",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
            child: success
                ? Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Complaint Submitted",
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your complaint has been submitted successfully. We will review it soon.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.descriptionText.withValues(alpha: 0.96),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        success = false;
                        submitted = false;
                        submitError = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Submit Another",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.6,
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Form(
              key: _formKey,
              autovalidateMode: submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Report a Complaint",
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tell us about the issue you faced in the app.",
                    style: TextStyle(
                      color: AppColors.descriptionText.withValues(alpha: 0.96),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _fieldCard(
                    child: TextFormField(
                      controller: subjectCtrl,
                      decoration: _decor(
                        "Subject",
                        prefix: const Icon(Icons.title_rounded),
                      ),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                      validator: _subjectValidator,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldCard(
                    child: TextFormField(
                      controller: descriptionCtrl,
                      maxLines: 6,
                      decoration: _decor(
                        "Describe your complaint",
                        prefix: const Icon(Icons.edit_note_rounded),
                      ),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                      validator: _descriptionValidator,
                    ),
                  ),
                  if (submitError != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyBackground.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.sosButton.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.sosButton.withValues(alpha: 0.95),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              submitError!,
                              style: TextStyle(
                                color: AppColors.sosButton.withValues(alpha: 0.98),
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submitComplaint,
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
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Submit Complaint",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}