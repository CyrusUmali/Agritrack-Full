import 'package:flutter/material.dart';
import './section_header.dart';
import './detail_field.dart';

class HouseholdInfoCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;

  const HouseholdInfoCard({
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
                title: 'Household Information', icon: Icons.group),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: DetailField(
                        label: 'Household Head',
                        value: farmer['householdHead'])),
                const SizedBox(width: 12),
                Expanded(
                    child: DetailField(
                        label: 'Civil Status', value: farmer['civilStatus'])),
              ],
            ),
            const SizedBox(height: 12),
            DetailField(
                label: 'Name of Spouse (if married)',
                value: farmer['spouseName'] ?? 'N/A'),
            const SizedBox(height: 12),
            DetailField(
                label: "Mother's Maiden Name",
                value: farmer['motherMaidenName']),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: DetailField(
                        label: 'Religion', value: farmer['religion'])),
                const SizedBox(width: 12),
                Expanded(
                    child: DetailField(
                        label: 'No. of Household Members',
                        value: farmer['householdMembers'].toString())),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: DetailField(
                        label: 'No. of Male Members',
                        value: farmer['maleMembers'].toString())),
                const SizedBox(width: 12),
                Expanded(
                    child: DetailField(
                        label: 'No. of Female Members',
                        value: farmer['femaleMembers'].toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
