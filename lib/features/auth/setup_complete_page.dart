import 'package:flutter/material.dart';
import 'theme.dart';

class SetupCompletePage extends StatelessWidget {
  const SetupCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // #D6EFE6 Main Background
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Spacer(),

              // 1. Success Icon/Illustration Area
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.background, // #F6F7F3
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sectionSeparator, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: AppColors.primary, // #2E7D7A
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Heading - #243333 Primary Text
              const Text(
                "All Set!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Subtext - #6F7F7D Description Text
              const Text(
                "Your emergency contacts and profile have been successfully configured. You're ready to use the app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.descriptionText,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // 4. Main Action Button - #2E7D7A
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Dashboard and clear navigation stack
                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Go to Dashboard",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}