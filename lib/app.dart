import 'package:flutter/material.dart';
import 'core/session/session_manager.dart';
import 'features/auth/welcome_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartScreen(),
    );
  }
}

/// This screen decides where to go based on login state
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<bool> _checkLogin() async {
    return await SessionManager.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading while checking session
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // User is logged in → go to dashboard
          return const DashboardScreen();
        } else {
          // Not logged in → welcome screen
          return const WelcomeScreen();
        }
      },
    );
  }
}
