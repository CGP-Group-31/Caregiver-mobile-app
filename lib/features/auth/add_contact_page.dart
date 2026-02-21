import 'package:flutter/material.dart';
import 'theme.dart';
import 'auth_service.dart';

class AddContactPage extends StatefulWidget {
  final int elderId;

  const AddContactPage({super.key, required this.elderId});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.createEmergencyContact(
        elderId: widget.elderId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relation: _relationController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        centerTitle: true,
        // FIX: Increase leadingWidth to prevent text wrapping
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _onSave,
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Added for Samsung feel
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Profile Placeholder
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.person, size: 50, color: AppColors.descriptionText),
                ),
              ),
              const SizedBox(height: 40),

              // Input Fields Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      _buildSamsungField(
                        controller: _nameController,
                        icon: Icons.person_outline,
                        label: "Name",
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
                      ),
                      const Divider(height: 1, indent: 60, endIndent: 20),
                      _buildSamsungField(
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        label: "Phone",
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter phone' : null,
                      ),
                      const Divider(height: 1, indent: 60, endIndent: 20),
                      _buildSamsungField(
                        controller: _relationController,
                        icon: Icons.family_restroom_outlined,
                        label: "Relation",
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter relation' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSamsungField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: AppColors.descriptionText, fontSize: 14),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorStyle: const TextStyle(height: 0.8),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}