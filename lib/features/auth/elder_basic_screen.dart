import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import 'auth_service.dart';
import 'medical_details_screen.dart';

class ElderBasicScreen extends StatefulWidget {
  const ElderBasicScreen({super.key});

  @override
  State<ElderBasicScreen> createState() => _ElderBasicScreenState();
}

class _ElderBasicScreenState extends State<ElderBasicScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final relationCtrl = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final caregiverId = await SessionManager.getUserId();

      final data = await AuthService.createElder(
        fullName: fullNameCtrl.text,
        email: emailCtrl.text,
        phone: phoneCtrl.text,
        password: passwordCtrl.text,
        dateOfBirth: dobCtrl.text,
        gender: genderCtrl.text,
        address: addressCtrl.text,
        caregiverId: caregiverId!,
        relationshipType: relationCtrl.text,
        isPrimary: true,
      );

      final elderId = data["user_id"];
      final relationshipId = data["relationship_id"];

      await SessionManager.saveElderData(elderId, relationshipId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const MedicalDetailsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        validator: (v) =>
        v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    dobCtrl.dispose();
    genderCtrl.dispose();
    addressCtrl.dispose();
    relationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Elder Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              field(fullNameCtrl, "Full Name"),
              field(emailCtrl, "Email"),
              field(phoneCtrl, "Phone"),
              field(passwordCtrl, "Password"),
              field(dobCtrl, "Date of Birth"),
              field(genderCtrl, "Gender"),
              field(addressCtrl, "Address"),
              field(relationCtrl, "Relationship"),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Next"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
