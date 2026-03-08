import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D7A); // teal
  static const Color mintBg = Color(0xFFD6EFE6); // light mint
  static const Color mintSoft = Color(0xFFBEE8DA); // input-ish mint
  static const Color surface = Color(0xFFF6F7F3); // soft white
  static const Color textDark = Color(0xFF243333); // dark
  static const Color textMuted = Color(0xFF6F7F7D); // muted gray
  static const Color warmAccent = Color(0xFFE6B566); // optional badge accent
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Soft background shapes (to match your login page vibe)
            Positioned(
              top: -size.width * 0.25,
              left: -size.width * 0.18,
              child: _BlobCircle(
                diameter: size.width * 0.70,
                color: AppColors.mintBg,
              ),
            ),
            Positioned(
              bottom: -size.width * 0.30,
              right: -size.width * 0.20,
              child: _BlobCircle(
                diameter: size.width * 0.80,
                color: AppColors.mintBg.withOpacity(0.95),
              ),
            ),

            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Small top chip (like "Caregiver Access")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.mintSoft.withOpacity(0.9),
                            ),
                          ),
                          child: const Text(
                            " TrustCare - Elder Care System",
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        const Text(
                          "Welcome ",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),

                       

                        const SizedBox(height: 22),

                        // Decorative mini row (icon + text)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.mintBg.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.mintSoft.withOpacity(0.9),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.health_and_safety_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "A safer, easier daily routine for elders and caregivers.",
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Primary button - Login
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Secondary button - Sign Up
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.55),
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Create account",
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // tiny footer
                        Center(
                          child: Text(
                            "Secure login • Elder care system",
                            style: TextStyle(
                              color: AppColors.textMuted.withOpacity(0.85),
                              fontSize: 12.2,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  final Widget child;
  const _MainCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.mintSoft.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BlobCircle extends StatelessWidget {
  final double diameter;
  final Color color;
  const _BlobCircle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(diameter / 2),
      ),
    );
  }
}
