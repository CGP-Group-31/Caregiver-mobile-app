import 'package:flutter/material.dart';

class MedicalDetailsScreen extends StatelessWidget {
  const MedicalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical Details")),
      body: const Center(
        child: Text(
          "Medical details form goes here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
