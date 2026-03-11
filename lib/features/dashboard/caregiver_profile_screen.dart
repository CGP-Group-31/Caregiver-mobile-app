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

      final data = res.data as Map<String, dynamic>;

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
      final msg = (e.response?.data is Map && (e.response?.data["detail"] != null))
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

  Future<Response<dynamic>> _tryUpdate({
    required int caregiverId,
    required Map<String, dynamic> payload,
  }) async {
    final base1 = "/api/v1/caregiver/caregiver-profile/$caregiverId";
    final base2 = "/api/v1/caregiver/caregiver-profile/$caregiverId/";
    final methods = ["PATCH", "PUT", "POST"];

    DioException? last405;

    for (final url in [base1, base2]) {
      for (final m in methods) {
        try {
          final res = await DioClient.dio.request(
            url,
            data: payload,
            options: Options(method: m),
          );
          return res;
        } on DioException catch (e) {
          final code = e.response?.statusCode;
          if (code == 405) {
            last405 = e;
            continue;
          }
          rethrow;
        }
      }
    }

    throw last405 ??
        DioException(
          requestOptions: RequestOptions(path: base1),
          error: "Method not allowed",
          response: Response(
            requestOptions: RequestOptions(path: base1),
            statusCode: 405,
          ),
        );
  }

  Future<void> _openEditSheet() async {
    final formKey = GlobalKey<FormState>();
    final phoneCtrl = TextEditingController(text: phone);
    final emailCtrl = TextEditingController(text: email);
    final addressCtrl = TextEditingController(text: address);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool localSaving = false;
        bool localSuccess = false;
        String? submitError;
        String? phoneServerError;
        String? emailServerError;
        String? addressServerError;

        InputDecoration decor(
            String label, {
              IconData? icon,
              String? errorText,
            }) {
          return InputDecoration(
            labelText: label,
            errorText: errorText,
            labelStyle: const TextStyle(
              color: AppColors.descriptionText,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: AppColors.containerBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.primary.withValues(alpha: 0.95))
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.textShade.withValues(alpha: 0.18),
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
                width: 1.1,
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
              fontWeight: FontWeight.w700,
              fontSize: 12.2,
            ),
          );
        }

        Future<void> closeSheet(BuildContext ctx) async {
          FocusManager.instance.primaryFocus?.unfocus();
          await Future.delayed(const Duration(milliseconds: 80));
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
          }
        }

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            void clearFieldErrors() {
              phoneServerError = null;
              emailServerError = null;
              addressServerError = null;
            }

            Future<void> save() async {
              FocusManager.instance.primaryFocus?.unfocus();

              setLocal(() {
                submitError = null;
                clearFieldErrors();
              });

              final valid = formKey.currentState?.validate() ?? false;
              if (!valid) return;

              final p = phoneCtrl.text.trim();
              final e = emailCtrl.text.trim();
              final a = addressCtrl.text.trim();

              setLocal(() {
                submitError = null;
                localSaving = true;
              });

              try {
                final caregiverId = await SessionManager.getUserId();
                if (caregiverId == null) {
                  setLocal(() {
                    localSaving = false;
                    submitError = "Session expired. Please login again.";
                  });
                  return;
                }

                final payload = {
                  "phone": p,
                  "address": a.isEmpty ? null : a,
                  "email": e,
                };

                await _tryUpdate(
                  caregiverId: caregiverId,
                  payload: payload,
                );

                if (!mounted) return;

                setState(() {
                  phone = p;
                  address = a;
                  email = e;
                });

                setLocal(() {
                  localSaving = false;
                  localSuccess = true;
                });
              } on DioException catch (ex) {
                final code = ex.response?.statusCode;
                final rawDetail = ex.response?.data is Map && ex.response?.data["detail"] != null
                    ? ex.response!.data["detail"].toString()
                    : "";

                final detail = rawDetail.toLowerCase();

                setLocal(() {
                  localSaving = false;
                  submitError = null;
                  clearFieldErrors();

                  if (detail.contains("address")) {
                    addressServerError = "Address cannot be empty";
                  } else if (detail.contains("email")) {
                    emailServerError = "This email is not accepted";
                  } else if (detail.contains("phone")) {
                    phoneServerError = "This phone number is not accepted";
                  } else if (code == 405) {
                    submitError = "Update method is not enabled in backend yet.";
                  } else {
                    submitError = rawDetail.isNotEmpty
                        ? rawDetail
                        : "Update failed. Please try again.";
                  }
                });

                formKey.currentState?.validate();
              } catch (_) {
                setLocal(() {
                  localSaving = false;
                  submitError = "Something went wrong. Please try again.";
                });
              }
            }

            return AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.mainBackground,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.textShade.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                          decoration: BoxDecoration(
                            color: AppColors.sectionBackground.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.textShade.withValues(alpha: 0.16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: localSuccess
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
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
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                "Profile Updated",
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Your caregiver profile details were updated successfully.",
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
                                  onPressed: () => closeSheet(ctx),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "Done",
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
                            key: formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Update your contact details below.",
                                  style: TextStyle(
                                    color: AppColors.descriptionText.withValues(alpha: 0.96),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  onChanged: (_) {
                                    if (phoneServerError != null || submitError != null) {
                                      setLocal(() {
                                        phoneServerError = null;
                                        submitError = null;
                                      });
                                    }
                                  },
                                  decoration: decor(
                                    "Phone",
                                    icon: Icons.call_rounded,
                                    errorText: phoneServerError,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  validator: (v) {
                                    if (phoneServerError != null) return phoneServerError;
                                    final value = (v ?? "").trim();
                                    if (value.isEmpty) return "Phone is required";
                                    if (!RegExp(r"^\d{10}$").hasMatch(value)) {
                                      return "Phone must be exactly 10 digits";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (emailServerError != null || submitError != null) {
                                      setLocal(() {
                                        emailServerError = null;
                                        submitError = null;
                                      });
                                    }
                                  },
                                  decoration: decor(
                                    "Email",
                                    icon: Icons.alternate_email_rounded,
                                    errorText: emailServerError,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  validator: (v) {
                                    if (emailServerError != null) return emailServerError;
                                    final value = (v ?? "").trim();
                                    if (value.isEmpty) return "Email is required";
                                    if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(value)) {
                                      return "Enter a valid email";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: addressCtrl,
                                  keyboardType: TextInputType.streetAddress,
                                  onChanged: (_) {
                                    if (addressServerError != null || submitError != null) {
                                      setLocal(() {
                                        addressServerError = null;
                                        submitError = null;
                                      });
                                    }
                                  },
                                  decoration: decor(
                                    "Address",
                                    icon: Icons.home_rounded,
                                    errorText: addressServerError,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  validator: (v) {
                                    if (addressServerError != null) return addressServerError;
                                    final value = (v ?? "").trim();
                                    if (value.length > 140) {
                                      return "Address is too long (max 140 characters)";
                                    }
                                    return null;
                                  },
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
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: localSaving ? null : () => closeSheet(ctx),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primaryText,
                                          side: BorderSide(
                                            color: AppColors.textShade.withValues(alpha: 0.22),
                                          ),
                                          backgroundColor: AppColors.containerBackground,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                        ),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: localSaving ? null : save,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                        ),
                                        child: localSaving
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                            : const Text(
                                          "Save Changes",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
  }

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
    final v = value.trim().isEmpty ? "-" : value.trim();

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
                  v,
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
                    icon: Icons.home_rounded,
                    label: "Address",
                    value: address,
                  ),
                ],
              ),
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