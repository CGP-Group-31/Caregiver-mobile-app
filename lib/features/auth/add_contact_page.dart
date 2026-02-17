import 'package:flutter/material.dart';
import 'theme.dart';

class AddContactPage extends StatelessWidget {
  const AddContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        centerTitle: true, // Samsung often centers titles in secondary pages
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Save",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Picture - Larger for better UX
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Icon(Icons.camera_alt, size: 40, color: AppColors.descriptionText),
              ),
            ),
            const SizedBox(height: 50),

            // Grouped Fields in a massive, rounded "Card"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(30), // Extra rounded
                ),
                child: Column(
                  children: [
                    _buildSamsungField(Icons.person, "Name", "Enter name"),
                    _buildDivider(),
                    _buildSamsungField(Icons.phone, "Phone", "Enter phone number", keyboardType: TextInputType.phone),
                    _buildDivider(),
                    _buildSamsungField(Icons.family_restroom, "Relation", "Son, Doctor, etc."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Divider with Samsung-style inset to align with text
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.mainBackground.withOpacity(0.5),
      indent: 65, // Aligns exactly with the start of the text field
      endIndent: 20,
    );
  }

  Widget _buildSamsungField(IconData icon, String label, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mainBackground.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 26), // Stronger icon presence
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500), // Larger text
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: InputBorder.none,
                isDense: false, // Allows the field to expand naturally
                labelStyle: const TextStyle(color: AppColors.descriptionText, fontSize: 15),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}