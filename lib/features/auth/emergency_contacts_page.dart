import 'package:flutter/material.dart';
import 'contact_model.dart';
import 'theme.dart';
import 'add_contact_page.dart';
import 'setup_complete_page.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List used for display
    List<ContactModel> dummyContacts = [
      ContactModel(name: "John Doe", phone: "0711234567", relation: "Son"),
      ContactModel(name: "Dr. Smith", phone: "0779876543", relation: "Doctor"),
    ];

    return Scaffold(
      // #D6EFE6 Main Screen Background
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        // #2E7D7A Primary for Nav Bar
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            // #243333 Primary Text Color
            const Text(
              "Your trusted contacts",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText
              ),
            ),
            const SizedBox(height: 20),

            // Samsung Grouped Container using #F6F7F3
            Container(
              decoration: BoxDecoration(
                color: AppColors.containerBackground, // #F6F7F3
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.sectionSeparator, width: 1), // #BEE8DA
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dummyContacts.length,
                // Divider using #BEE8DA
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  indent: 75,
                  endIndent: 20,
                  color: AppColors.sectionSeparator,
                ),
                itemBuilder: (context, index) {
                  final contact = dummyContacts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      // Soft background using separator color
                      backgroundColor: AppColors.sectionSeparator,
                      radius: 25,
                      child: Text(
                        contact.name[0],
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    title: Text(contact.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryText)),
                    // #6F7F7D for description
                    subtitle: Text("${contact.relation} • ${contact.phone}",
                        style: const TextStyle(color: AppColors.descriptionText, fontSize: 14)),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: AppColors.mainBackground,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary, size: 22),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // Add Contact - Using Section Separator color for button background if needed
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddContactPage())),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("Add New Contact"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Continue - Using #2E7D7A Main Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupCompletePage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}