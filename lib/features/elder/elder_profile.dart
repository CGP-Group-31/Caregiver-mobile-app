import 'package:flutter/material.dart';
import 'elder_model.dart';
import 'elder_service.dart';
import 'health_details_page.dart';
import 'medical_record_screen.dart';
import 'edit_elder_profile_screen.dart';
import '../location/caregiver_view_location.dart';
import '../auth/theme.dart';

class ElderProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const ElderProfileScreen({super.key, this.onBackToHome});

  @override
  State<ElderProfileScreen> createState() => _ElderProfileScreenState();
}

class _ElderProfileScreenState extends State<ElderProfileScreen> {
  late Future<ElderModel> _elderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _elderDetailsFuture = ElderService.getElderDetails();
    });
  }

  int _calculateAge(String dob) {
    if (dob.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: FutureBuilder<ElderModel>(
        future: _elderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load profile.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          }

          final elder = snapshot.data!;

          return Stack(
            children: [
              Positioned(
                top: -100,
                right: -50,
                child: CircleAvatar(
                  radius: 150,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryText, size: 20),
                      onPressed: () {
                        if (widget.onBackToHome != null){
                          widget.onBackToHome!();
                        } else if (Navigator.canPop(context)){
                          Navigator.pop(context);
                        }
                      },
                    ),
                    centerTitle: true,
                    title: const Text(
                      "ELDER PROFILE",
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          

                          _buildMinimizedSummaryCard(elder),
                          
                          const SizedBox(height: 40),
                          

                          _buildNavCard(
                            title: "Health Details",
                            description: "Vitals & Medical History",
                            icon: Icons.favorite_outline_rounded,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthDetailsPage())),
                          ),
                          
                          _buildNavCard(
                            title: "Medical Background",
                            description: "Allergies, Chronic Conditions & Meds",
                            icon: Icons.history_edu_rounded,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalRecordScreen())),
                          ),
                          
                          _buildNavCard(
                            title: "Location",
                            description: "Live Tracking & History",
                            icon: Icons.near_me_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverViewLocation())),
                          ),

                          _buildNavCard(
                            title: "Weekly Reports",
                            description: "AI Health Analysis",
                            icon: Icons.auto_graph_rounded,
                            onTap: () {
                              // Weekly Reports functionality is handled by teammate
                            },
                          ),
                          
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMinimizedSummaryCard(ElderModel elder) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                elder.name.isNotEmpty && elder.name != "N/A" ? elder.name.substring(0, 2).toUpperCase() : "JD",
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            elder.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          Text(
            "${elder.gender} • ${_calculateAge(elder.dateOfBirth)} Years",
            style: const TextStyle(color: AppColors.descriptionText, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FBFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    elder.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.descriptionText, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditElderProfileScreen(elder: elder)),
                    );
                    if (updated == true) _loadData();
                  },
                  child: const Text(
                    "ELDER DETAILS", 
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryText, letterSpacing: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: AppColors.descriptionText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textShade),
            ],
          ),
        ),
      ),
    );
  }
}
