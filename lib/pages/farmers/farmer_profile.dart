import 'package:flareline/pages/farmers/farmers_widget/personal_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/layout.dart';
import './farmers_widget/household_info_card.dart';
import './farmers_widget/farm_profile_card.dart';
import './farmers_widget/emergency_contacts_card.dart';
import './farmers_widget/household_info_card.dart';

class FarmersProfile extends LayoutWidget {
  final Map<String, dynamic> farmer;

  const FarmersProfile({super.key, required this.farmer});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Farmer Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return FarmersProfileDesktop(farmer: farmerData);
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return FarmersProfileMobile(farmer: farmerData);
  }
}

class FarmersProfileDesktop extends StatelessWidget {
  final Map<String, dynamic> farmer;

  const FarmersProfileDesktop({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ProfileHeader(farmer: farmer),
            const SizedBox(height: 24),
            PersonalInfoCard(farmer: farmer),
            const SizedBox(height: 16),
            HouseholdInfoCard(farmer: farmer),
            const SizedBox(height: 16),
            EmergencyContactsCard(farmer: farmer),
            const SizedBox(height: 16),
            FarmProfileCard(farmer: farmer),
          ],
        ),
      ),
    );
  }
}

class FarmersProfileMobile extends StatelessWidget {
  final Map<String, dynamic> farmer;

  const FarmersProfileMobile({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _ProfileHeader(farmer: farmer, isMobile: true),
            const SizedBox(height: 16),
            PersonalInfoCard(farmer: farmer, isMobile: true),
            const SizedBox(height: 16),
            HouseholdInfoCard(farmer: farmer, isMobile: true),
            const SizedBox(height: 16),
            EmergencyContactsCard(farmer: farmer, isMobile: true),
            const SizedBox(height: 16),
            FarmProfileCard(farmer: farmer, isMobile: true),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;

  const _ProfileHeader({required this.farmer, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: isMobile ? 150 : 200,
            width: double.infinity,
            child: Image.asset(
              'assets/cover/cover-01.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: isMobile ? 40 : 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: isMobile ? 48 : 72,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                child: ClipOval(
                  child: Image.asset(
                    'assets/user/user-01.png',
                    width: isMobile ? 80 : 120,
                    height: isMobile ? 80 : 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                farmer['farmerName'] ?? 'Unknown Farmer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

final farmerData = {
  'farmerName': 'Juan Dela Cruz',
  'surname': 'Dela Cruz',
  'firstName': 'Juan',
  'middleName': 'Santos',
  'extension': 'Jr.',
  'gender': 'Male',
  'addressLine1': '123 Purok 5',
  'addressLine2': 'Sitio Pag-asa',
  'barangay': 'Barangay 1',
  'city': 'Cityville',
  'province': 'Provinceville',
  'region': 'Regionville',
  'contactNumber': '09123456789',
  'birthDate': 'January 1, 1980',
  'birthPlace': 'Cityville',
  'education': 'College Graduate',
  'disability': 'None',
  'is4ps': false,
  'isIndigenous': false,
  'governmentId': '123-456-789-000',
  'association': 'Farmers Cooperative',
  // Add all other required fields...
  'farms': [
    {
      'location': 'Near the river',
      'barangay': 'Barangay 1',
      'city': 'Cityville',
      'area': 5.2,
      'commodities': ['Rice', 'Corn'],
      'livestockCount': 0,
      'poultryCount': 0,
    }
  ]
};
