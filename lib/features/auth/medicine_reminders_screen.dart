import 'package:flutter/material.dart';

class MedicineRemindersScreen extends StatelessWidget {
  const MedicineRemindersScreen({super.key});

  static const Color cPrimary = Color(0xFF2E7D7A);
  static const Color cBg = Color(0xFFD6EFE6);
  static const Color cTextDark = Color(0xFF243333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        backgroundColor: cPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          "Medicine & Reminders",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(
        child: Text(
          "Dummy Medicine & Reminders Page ✅",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cTextDark,
          ),
        ),
      ),
    );
  }
}
