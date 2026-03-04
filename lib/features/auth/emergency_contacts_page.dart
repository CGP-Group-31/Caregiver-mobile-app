import 'package:flutter/material.dart';
import 'contact_model.dart';
import 'auth_service.dart';
import 'theme.dart';
import 'add_contact_page.dart';
import 'setup_complete_page.dart';

class EmergencyContactsPage extends StatefulWidget {
  final int elderId;

  const EmergencyContactsPage({super.key, required this.elderId});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  // --- NEW: Add a key to force refresh ---
  Key _futureKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.mainBackground,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Emergency Contacts",
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Container(
                color: AppColors.mainBackground,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.contact_phone_outlined, size: 50, color: AppColors.primary),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.antiAlias, // <-- Add this to clip the list
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: FutureBuilder<List<ContactModel>>(
                key: _futureKey, // <-- Use the key here
                future: AuthService.getEmergencyContacts(widget.elderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error.toString()}"));
                  }

                  var contacts = snapshot.data ?? [];

                  if (contacts.isEmpty) {
                    return const Center(
                      child: Text("No contacts added yet.",
                          style: TextStyle(color: AppColors.descriptionText)),
                    );
                  }

                  // --- NEW: Sort list to show primary contact first ---
                  contacts.sort((a, b) {
                    if (b.isPrimary) return 1;
                    if (a.isPrimary) return -1;
                    return a.name.compareTo(b.name); // Keep alphabetical order otherwise
                  });

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) =>
                    const Divider(indent: 70, endIndent: 20, height: 1),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '#',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                        ),
                        title: Text(contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                        subtitle: Text('${contact.relation} • ${contact.phone}',
                            style: const TextStyle(color: AppColors.descriptionText)),
                        // --- NEW: Show a star for the primary contact ---
                        trailing: contact.isPrimary
                            ? const Icon(Icons.star_rounded, color: AppColors.primary, size: 24)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      color: AppColors.mainBackground,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddContactPage(elderId: widget.elderId)),
                );
                if (result == true) {
                  // --- NEW: Refresh the FutureBuilder ---
                  setState(() {
                    _futureKey = UniqueKey();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Contact"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetupCompletePage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text("Finish Setup", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
