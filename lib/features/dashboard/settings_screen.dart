import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionManager.logout();

    if(!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen()),
        (_) => false,
    );
  }
  
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D7A),
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFFF6F7F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFC62828)),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Color(0xFF243333),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _logout(context),
          ),
        ),
      ),
    );
  }
}