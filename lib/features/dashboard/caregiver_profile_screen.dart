import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/session/session_manager.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/theme.dart'; // adjust path if needed

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
        fullName = (data["FullName"] ?? "").toString();
        email = (data["Email"] ?? "").toString();
        phone = (data["Phone"] ?? "").toString();
        dob = (data["DateOfBirth"] ?? "").toString();
        gender = (data["Gender"] ?? "").toString();
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
                  value.isEmpty ? "-" : value,
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
              // PROFILE HEADER
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.sectionBackground
                                .withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textShade
                                  .withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName.isEmpty ? "Caregiver" : fullName,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email.isEmpty ? "-" : email,
                      style: TextStyle(
                        color:
                        AppColors.descriptionText.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
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
                ],
              ),

              // ACCOUNT (Email as Username)
              _sectionTitle("Account"),
              _card(
                children: [
                  _rowItem(
                    icon: Icons.alternate_email_rounded,
                    label: "Username (Email)",
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