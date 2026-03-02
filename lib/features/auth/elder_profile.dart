import 'package:flutter/material.dart';
import '../elder/elder_model.dart';
import '../elder/elder_service.dart';
import '../elder/medical_record_screen.dart';
import 'theme.dart';

class ElderProfileScreen extends StatefulWidget {
  const ElderProfileScreen({super.key});

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
    _elderDetailsFuture = ElderService.getElderDetails();
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
                      onPressed: () => setState(_loadData),
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
                      onPressed: () => Navigator.pop(context),
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
                        children: [
                          const SizedBox(height: 20),
                          _buildPremiumProfileCard(elder),
                          const SizedBox(height: 40),
                          _buildPremiumNavTile(
                            context,
                            title: "Health Details",
                            description: "Vitals, History & Meds",
                            icon: Icons.favorite_outline_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MedicalRecordScreen()),
                              );
                            },
                          ),
                          _buildPremiumNavTile(
                            context,
                            title: "Weekly Reports",
                            description: "AI Health Analysis",
                            icon: Icons.auto_graph_rounded,
                            onTap: () {},
                          ),
                          _buildPremiumNavTile(
                            context,
                            title: "Location",
                            description: "Live Tracking & History",
                            icon: Icons.near_me_outlined,
                            onTap: () {},
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

  Widget _buildPremiumProfileCard(ElderModel elder) {
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
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                elder.name.isNotEmpty && elder.name != "N/A" ? elder.name.substring(0, 2).toUpperCase() : "JD",
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            elder.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mainBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${elder.gender} • ${_calculateAge(elder.dateOfBirth)} Years",
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FBFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    elder.address,
                    style: const TextStyle(color: AppColors.descriptionText, fontSize: 13),
                  ),
                ),
                const Text(
                  "EDIT",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumNavTile(BuildContext context,
      {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
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
