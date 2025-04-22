import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
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
    return CommonCard(
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
                      value: farmer['householdHead']?.toString() ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(
                  child: DetailField(
                      label: 'Civil Status',
                      value: farmer['civilStatus']?.toString() ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 12),
          DetailField(
              label: 'Name of Spouse (if married)',
              value: farmer['spouseName']?.toString() ?? 'N/A'),
          const SizedBox(height: 12),
          DetailField(
              label: "Mother's Maiden Name",
              value: farmer['motherMaidenName']?.toString() ?? 'N/A'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: DetailField(
                      label: 'Religion',
                      value: farmer['religion']?.toString() ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(
                  child: DetailField(
                      label: 'No. of Household Members',
                      value: farmer['householdMembers']?.toString() ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: DetailField(
                      label: 'No. of Male Members',
                      value: farmer['maleMembers']?.toString() ?? 'N/A')),
              const SizedBox(width: 12),
              Expanded(
                  child: DetailField(
                      label: 'No. of Female Members',
                      value: farmer['femaleMembers']?.toString() ?? 'N/A')),
            ],
          ),
        ],
      ),
    );
  }
}
