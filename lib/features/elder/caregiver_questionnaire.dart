import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../auth/theme.dart';

class AddMoreInformationScreen extends StatefulWidget {
  const AddMoreInformationScreen({super.key});

  @override
  State<AddMoreInformationScreen> createState() =>
      _AddMoreInformationScreenState();
}

class _AddMoreInformationScreenState extends State<AddMoreInformationScreen> {

  final _cognitiveController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _socialController = TextEditingController();
  final _healthController = TextEditingController();
  final _specialController = TextEditingController();

  bool _loading = false;

  Future<void> _submitInfo() async {

    setState(() => _loading = true);

    try {
      final now = DateTime.now();

      await DioClient.dio.post(
        "/api/v1/caregiver/additional-info/",
        data: {
          "elder_id": 1,
          "caregiver_id": 1,
          "cognitive_behavior_notes": _cognitiveController.text,
          "preferences": _preferencesController.text,
          "social_emotional_behavior_notes": _socialController.text,
          "health_goals": _healthController.text,
          "special_notes_observations": _specialController.text,
          "phone_date": now.toIso8601String().split("T")[0],
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Information submitted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("It's available on Sunday 15.00 to 23.59")),
      );

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cognitiveController.dispose();
    _preferencesController.dispose();
    _socialController.dispose();
    _healthController.dispose();
    _specialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add Information",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0,5),
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Center(
                  child: Text(
                    "COMPANION BEHAVIOURS",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Below data will be used to provide more personalized and better companion experience.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.descriptionText,
                  ),
                ),

                const SizedBox(height: 25),

                _inputBox(
                  controller: _cognitiveController,
                  hint: "Cognitive behavior notes",
                ),
                const SizedBox(height: 25),

                _inputBox(
                  controller: _preferencesController,
                  hint: "Preferences",
                ),

                const SizedBox(height: 25),

                _inputBox(
                  controller: _socialController,
                  hint: "Social & emotional behavior",
                ),
                const SizedBox(height: 25),

                _inputBox(
                  controller: _healthController,
                  hint: "Health goals",
                ),
                const SizedBox(height: 25),

                _inputBox(
                  controller: _specialController,
                  hint: "Special notes / observations",
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical:14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _loading ? null : _submitInfo,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Submit Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.only(bottom:10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize:16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  static Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          hint,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          maxLines: maxLines,

          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),

          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.sectionBackground,

            hintText: "Enter $hint",

            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}