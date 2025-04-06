import 'package:flutter/material.dart';
import './section_header.dart';
import './detail_field.dart';

class PersonalInfoCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;

  const PersonalInfoCard({
    super.key,
    required this.farmer,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    // Helper function to safely get values from the farmer map
    String getValue(String key) => farmer[key]?.toString() ?? 'Not specified';

    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
                title: 'Personal Information', icon: Icons.person),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: DetailField(
                        label: 'Surname', value: getValue('surname'))),
                const SizedBox(width: 12),
                Expanded(
                    child: DetailField(
                        label: 'First Name', value: getValue('firstName'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: DetailField(
                        label: 'Middle Name', value: getValue('middleName'))),
                const SizedBox(width: 12),
                Expanded(
                    flex: 1,
                    child: DetailField(
                        label: 'Extension', value: getValue('extension'))),
                const SizedBox(width: 12),
                Expanded(
                    flex: 1,
                    child:
                        DetailField(label: 'Sex', value: getValue('gender'))),
              ],
            ),
            // Rest of the widget remains the same...
          ],
        ),
      ),
    );
  }
}
