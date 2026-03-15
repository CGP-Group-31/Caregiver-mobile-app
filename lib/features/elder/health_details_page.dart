import 'package:flutter/material.dart';
import '../auth/theme.dart';
import 'vitals_show_page.dart';
import 'vitals_add_page.dart';

class HealthDetailsPage extends StatelessWidget {
  const HealthDetailsPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Health Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle(
            title: "Vitals",
            subtitle: "Track and review health measurements",
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: "View Vitals",
                  subtitle: "Last 3 per category",
                  icon: Icons.monitor_heart_rounded,
                  bg: AppColors.containerBackground,
                  onTap: () => _open(context, const VitalsShowPage()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: "Add Vitals",
                  subtitle: "Record a new value",
                  icon: Icons.add_chart_rounded,
                  bg: AppColors.containerBackground,
                  onTap: () => _open(context, const VitalsAddPage()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _SectionTitle(
            title: "Coming soon",
            subtitle: "Add more health data modules here",
          ),
          const SizedBox(height: 12),

          _DisabledCard(
            title: "Allergies",
            subtitle: "Save allergies & reactions",
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 10),
          _DisabledCard(
            title: "Medical Conditions",
            subtitle: "Chronic conditions & history",
            icon: Icons.medical_information_rounded,
          ),
          const SizedBox(height: 10),
          _DisabledCard(
            title: "Reports / Documents",
            subtitle: "Upload lab reports & files",
            icon: Icons.folder_rounded,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.descriptionText,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sectionSeparator),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 6),
              color: Color(0x12000000),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.sectionBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.descriptionText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DisabledCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.containerBackground.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sectionSeparator),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.descriptionText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.descriptionText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_rounded, color: AppColors.descriptionText),
        ],
      ),
    );
  }
}
