import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../../features/auth/theme.dart';
import '../auth/login_screen.dart';
import 'caregiver_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout(BuildContext context) async {
    await SessionManager.logout();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.containerBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Logout?",
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "You will need to login again to access the app.",
          style: TextStyle(
            color: AppColors.primaryText.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.descriptionText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (res == true) {
      if (!mounted) return;
      await _logout(context);
    }
  }

  void _openPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.containerBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            "TrustCare collects only the information necessary to provide caregiving features, including caregiver details, elder medical information, reminders, and optional location and other relevant data.\n\n"
                "All data is transmitted securely and used solely to support app functionality. We do not sell or share personal data for marketing purposes.\n\n"
                "TrustCare does not provide medical advice and should not replace professional healthcare services.",
            style: TextStyle(
              color: AppColors.primaryText.withValues(alpha: 0.78),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.containerBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "About",
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          "TrustCare — Caregiver App\n\n"
              "TrustCare helps caregivers support elderly loved ones by managing medical information, reminders, alerts, and safety features.\n\n"
              "TrustCare is a support tool and does not replace professional medical advice or emergency services.\n\n"
              "Version: 1.0.0",
          style: TextStyle(
            color: AppColors.primaryText.withValues(alpha: 0.78),
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CaregiverProfileScreen()),
    );
  }

  // ----- UI helpers -----
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

  Widget _settingsCard({required List<Widget> children}) {
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

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.textShade.withValues(alpha: 0.14),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
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
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.8,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.descriptionText.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.6,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textShade.withValues(alpha: 0.75),
              ),
          ],
        ),
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
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ACCOUNT
              _sectionTitle("Account"),
              _settingsCard(
                children: [
                  _tile(
                    icon: Icons.person_rounded,
                    title: "Profile",
                    subtitle: "View caregiver details",
                    onTap: _goToProfile,
                  ),
                ],
              ),

              // SUPPORT
              _sectionTitle("Support"),
              _settingsCard(
                children: [
                  _tile(
                    icon: Icons.privacy_tip_rounded,
                    title: "Privacy Policy",
                    subtitle: "Read how data is handled",
                    onTap: _openPrivacyPolicy,
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.info_rounded,
                    title: "About",
                    subtitle: "App version and information",
                    onTap: _openAbout,
                  ),
                ],
              ),

              // SESSION
              _sectionTitle("Session"),
              _settingsCard(
                children: [
                  _tile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    subtitle: "Sign out from this device",
                    iconColor: AppColors.sosButton,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.sosButton.withValues(alpha: 0.9),
                    ),
                    onTap: _confirmLogout,
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