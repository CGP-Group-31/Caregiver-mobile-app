import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/session/session_manager.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/theme.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  bool loading = true;
  String? error;

  // Fetched data
  String fullName = "";
  String email = "";
  String phone = "";
  String dob = "";
  String gender = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final caregiverId = await SessionManager.getUserId();
      if (caregiverId == null) {
        setState(() {
          loading = false;
          error = "No caregiver session found. Please login again.";
        });
        return;
      }

      final res = await DioClient.dio.get(
        "/api/v1/caregiver/caregiver-profile/",
        queryParameters: {"caregiver_id": caregiverId},
      );

      final data = (res.data is Map)
          ? (res.data as Map<String, dynamic>)
          : <String, dynamic>{};

      setState(() {
        fullName = (data["FullName"] ?? data["full_name"] ?? "").toString();
        email = (data["Email"] ?? data["email"] ?? "").toString();
        phone = (data["Phone"] ?? data["phone"] ?? "").toString();
        dob = (data["DateOfBirth"] ?? data["date_of_birth"] ?? "").toString();
        gender = (data["Gender"] ?? data["gender"] ?? "").toString();
        address = (data["Address"] ?? data["address"] ?? "").toString();
        loading = false;
      });
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data["detail"] != null)
          ? e.response?.data["detail"].toString()
          : "Failed to load profile";
      setState(() {
        loading = false;
        error = msg;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = "Something went wrong";
      });
    }
  }

  // ---------- EDIT POPUP ----------
  Future<void> _openEditSheet() async {
    final caregiverId = await SessionManager.getUserId();
    if (caregiverId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No caregiver session found. Please login again.")),
      );
      return;
    }

    final phoneCtrl = TextEditingController(text: phone);
    final emailCtrl = TextEditingController(text: email);
    final addressCtrl = TextEditingController(text: address);

    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? apiError;

    String? emailValidator(String? v) {
      final value = (v ?? "").trim();
      if (value.isEmpty) return "Email is required";
      if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(value)) {
        return "Enter a valid email";
      }
      return null;
    }

    String? phoneValidator(String? v) {
      final value = (v ?? "").trim();
      if (value.isEmpty) return "Phone is required";
      final digits = value.replaceAll(RegExp(r"\D"), "");
      if (digits.length < 9 || digits.length > 15) {
        return "Enter a valid phone number";
      }
      return null;
    }

    String? addressValidator(String? v) {
      final value = (v ?? "").trim();
      if (value.isEmpty) return "Address is required";
      if (value.length < 5) return "Address is too short";
      if (value.length > 180) return "Address is too long";
      return null;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.containerBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> save() async {
              FocusScope.of(ctx).unfocus();
              apiError = null;

              final ok = formKey.currentState?.validate() ?? false;
              if (!ok) {
                setLocal(() {});
                return;
              }

              setLocal(() => saving = true);

              try {
                // ✅ Update API (password + full_name ignored)
                await DioClient.dio.put(
                  "/api/v1/caregiver/caregiver-profile/$caregiverId",
                  data: {
                    "phone": phoneCtrl.text.trim(),
                    "address": addressCtrl.text.trim(),
                    "email": emailCtrl.text.trim(),
                  },
                );

                // Update UI immediately
                if (!mounted) return;
                setState(() {
                  phone = phoneCtrl.text.trim();
                  address = addressCtrl.text.trim();
                  email = emailCtrl.text.trim();
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile updated successfully")),
                );
              } on DioException catch (e) {
                final detail = (e.response?.data is Map && e.response?.data["detail"] != null)
                    ? e.response?.data["detail"].toString()
                    : "Failed to update profile";
                setLocal(() {
                  apiError = detail;
                  saving = false;
                });
              } catch (_) {
                setLocal(() {
                  apiError = "Something went wrong";
                  saving = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textShade.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (apiError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyBackground.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.sosButton.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        apiError!,
                        style: TextStyle(
                          color: AppColors.sosButton.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _editField(
                          controller: phoneCtrl,
                          label: "Phone",
                          keyboardType: TextInputType.phone,
                          validator: phoneValidator,
                        ),
                        const SizedBox(height: 10),
                        _editField(
                          controller: emailCtrl,
                          label: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: emailValidator,
                        ),
                        const SizedBox(height: 10),
                        _editField(
                          controller: addressCtrl,
                          label: "Address",
                          keyboardType: TextInputType.streetAddress,
                          maxLines: 2,
                          validator: addressValidator,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: saving ? null : save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Save",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _editField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.descriptionText.withValues(alpha: 0.95),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: AppColors.sectionBackground.withValues(alpha: 0.28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.textShade.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.textShade.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.6,
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textShade.withValues(alpha: 0.18),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: AppColors.textShade.withValues(alpha: 0.14),
  );

  Widget _rowItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.sectionBackground.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.descriptionText.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? "-" : value.trim(),
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: "Edit",
            onPressed: loading ? null : _openEditSheet,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 38,
                  color: AppColors.sosButton.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 10),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _loadProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    "Retry",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.sectionBackground.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textShade.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName.trim().isEmpty ? "Caregiver" : fullName.trim(),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // BASIC INFO
              _sectionTitle("Basic Info"),
              _card(
                children: [
                  _rowItem(
                    icon: Icons.call_rounded,
                    label: "Phone",
                    value: phone,
                  ),
                  _divider(),
                  _rowItem(
                    icon: Icons.cake_rounded,
                    label: "Date of Birth",
                    value: dob,
                  ),
                  _divider(),
                  _rowItem(
                    icon: Icons.wc_rounded,
                    label: "Gender",
                    value: gender,
                  ),
                  _divider(),
                  _rowItem(
                    icon: Icons.location_on_rounded,
                    label: "Address",
                    value: address,
                  ),
                ],
              ),

              // ACCOUNT
              _sectionTitle("Account"),
              _card(
                children: [
                  _rowItem(
                    icon: Icons.alternate_email_rounded,
                    label: "Email",
                    value: email,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}