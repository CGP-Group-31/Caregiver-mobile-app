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

  Future<void> _openEditDialog() async {
    final phoneCtrl = TextEditingController(text: phone);
    final emailCtrl = TextEditingController(text: email);
    final addressCtrl = TextEditingController(text: address);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool localSaving = false;
        String? localError;
        bool localSuccess = false;

        InputDecoration decor(String label, {IconData? icon}) {
          return InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.containerBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.primary.withValues(alpha: 0.9))
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.textShade.withValues(alpha: 0.22),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
          );
        }

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> save() async {
              FocusScope.of(ctx).unfocus();

              final p = phoneCtrl.text.trim();
              final e = emailCtrl.text.trim();
              final a = addressCtrl.text.trim();

              if (p.isEmpty) {
                setLocal(() => localError = "Phone is required");
                return;
              }

              final digits = p.replaceAll(RegExp(r"\D"), "");
              if (digits.length < 9 || digits.length > 15) {
                setLocal(() => localError = "Enter a valid phone number");
                return;
              }

              if (e.isEmpty) {
                setLocal(() => localError = "Email is required");
                return;
              }

              if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(e)) {
                setLocal(() => localError = "Enter a valid email");
                return;
              }

              if (a.isNotEmpty && a.length > 140) {
                setLocal(() => localError = "Address is too long (max 140)");
                return;
              }

              setLocal(() {
                localError = null;
                localSaving = true;
              });

              try {
                final caregiverId = await SessionManager.getUserId();
                if (caregiverId == null) {
                  setLocal(() {
                    localSaving = false;
                    localError = "Session expired. Please login again.";
                  });
                  return;
                }

                final payload = {
                  "phone": p,
                  "address": a,
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

                String msg = "Update failed. Please try again.";

                if (ex.response?.data is Map && ex.response?.data["detail"] != null) {
                  msg = ex.response!.data["detail"].toString();
                } else if (code == 405) {
                  msg = "Update method is not enabled in backend yet.";
                }

                setLocal(() {
                  localSaving = false;
                  localError = msg;
                });
              } catch (_) {
                setLocal(() {
                  localSaving = false;
                  localError = "Something went wrong. Please try again.";
                });
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.containerBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (localSuccess) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.sectionBackground.withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.primary.withValues(alpha: 0.95)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Profile updated successfully",
                                style: TextStyle(
                                  color: AppColors.primaryText.withValues(alpha: 0.90),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: decor("Phone", icon: Icons.call_rounded),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: decor("Email", icon: Icons.alternate_email_rounded),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressCtrl,
                        keyboardType: TextInputType.streetAddress,
                        decoration: decor("Address", icon: Icons.home_rounded),
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (localError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyBackground.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.sosButton.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            localError!,
                            style: TextStyle(
                              color: AppColors.sosButton.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: localSuccess
                  ? [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ]
                  : [
                TextButton(
                  onPressed: localSaving ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: AppColors.descriptionText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: localSaving ? null : save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
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
            onPressed: loading ? null : _openEditDialog,
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