import 'package:flutter/material.dart';
import './section_header.dart';
import './detail_field.dart';

class EmergencyContactsCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;

  const EmergencyContactsCard({
    super.key,
    required this.farmer,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
                title: 'Emergency Contacts', icon: Icons.emergency),
            const SizedBox(height: 16),
            DetailField(
                label: 'Person to Notify',
                value: farmer['emergencyContactName']),
            const SizedBox(height: 12),
            DetailField(
                label: 'Contact Number',
                value: farmer['emergencyContactNumber']),
            const SizedBox(height: 12),
            DetailField(
                label: 'Relationship',
                value: farmer['emergencyContactRelationship']),
          ],
        ),
      ),
    );
  }
}
