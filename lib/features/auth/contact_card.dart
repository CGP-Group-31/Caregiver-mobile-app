import 'package:flutter/material.dart';
import 'contact_model.dart';
import 'theme.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;

  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.sectionBackground,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(contact.name, style: const TextStyle(color: AppColors.primaryText)),
        subtitle: Text('${contact.relation} - ${contact.phone}', style: const TextStyle(color: AppColors.descriptionText)),
      ),
    );
  }
}
