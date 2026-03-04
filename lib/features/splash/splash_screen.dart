import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../auth/welcome_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/notifications/fcm_manager.dart';
import '../dashboard/main_navigation_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color backgroundColor = Color(0xFFE6F4EF);
  static const Color primaryBlue = Color(0xFF2F6FED);
  static const Color darkText = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((message) {
      print("FCM Foreground: ${message.notification?.title} | ${message.notification?.body}");
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    bool isLoggedIn = await SessionManager.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        isLoggedIn ? const MainNavigationScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// LOGO IMAGE
                Image.asset(
                  "assets/images/Trust.png",
                  width: 260,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                /// Loading indicator
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: darkText.withOpacity(0.1),
                    valueColor:
                    const AlwaysStoppedAnimation(primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
