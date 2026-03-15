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
          "elder_id": 1,   // TODO: replace with session elder id
          "caregiver_id": 1, // TODO: replace with session caregiver id
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
        SnackBar(content: Text("Error: $e")),
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
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// BACK BUTTON
              Row(
                children: [

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Text(
                    "Add Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Center(
                child: Text(
                  "ADD MORE INFORMATION",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              const Text(
                "Below data will be used to provide more personalized and better companion experience to user.",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.descriptionText,
                ),
              ),

              const SizedBox(height: 25),

              /// FIELD 1
              _sectionTitle("1. Cognitive behavior notes about elder"),
              const SizedBox(height: 8),
              _inputBox(
                controller: _cognitiveController,
                hint: "Ex: Forgets meals",
              ),

              const SizedBox(height: 20),

              /// FIELD 2
              _sectionTitle("2. Preferences of the elder"),
              const SizedBox(height: 8),
              _inputBox(
                controller: _preferencesController,
                hint:
                "Ex: Calms down listening to Pirith / Dislike loud places",
              ),

              const SizedBox(height: 20),

              /// FIELD 3
              _sectionTitle("3. Social & Emotional behavior notes"),
              const SizedBox(height: 8),
              _inputBox(
                controller: _socialController,
                hint: "Ex: Anxious when alone",
              ),

              const SizedBox(height: 20),

              /// FIELD 4
              _sectionTitle("4. Health Goals of the elder"),
              const SizedBox(height: 8),
              _inputBox(
                controller: _healthController,
                hint: "Ex: Reduce Blood pressure level",
              ),

              const SizedBox(height: 20),

              /// FIELD 5
              _sectionTitle("5. Other special notes/observations"),
              const SizedBox(height: 8),
              _inputBox(
                controller: _specialController,
                hint: "",
                maxLines: 4,
              ),

              const SizedBox(height: 40),

              /// DONE BUTTON
              Align(
                alignment: Alignment.centerRight,

                child: SizedBox(
                  width: 110,
                  height: 45,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onPressed: _loading ? null : _submitInfo,

                    child: Text(
                      _loading ? "Saving..." : "Done",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// SECTION TITLE
  static Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  /// INPUT BOX
  static Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}