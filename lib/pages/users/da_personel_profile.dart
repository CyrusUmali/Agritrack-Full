import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/layout.dart';

class DAOfficerProfile extends LayoutWidget {
  final Map<String, dynamic> daUser;

  const DAOfficerProfile({super.key, required this.daUser});

  @override
  String breakTabTitle(BuildContext context) {
    return 'DA Officer Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return DAProfileDesktop(daUser: daUser);
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return DAProfileMobile(daUser: daUser);
  }
}

class DAProfileDesktop extends StatelessWidget {
  final Map<String, dynamic> daUser;

  const DAProfileDesktop({super.key, required this.daUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ProfileHeader(user: daUser),
            const SizedBox(height: 24),
            _UserInfoCard(user: daUser),
            const SizedBox(height: 16),
            _RecentActivitiesCard(),
          ],
        ),
      ),
    );
  }
}

class DAProfileMobile extends StatelessWidget {
  final Map<String, dynamic> daUser;

  const DAProfileMobile({super.key, required this.daUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _ProfileHeader(user: daUser, isMobile: true),
            const SizedBox(height: 16),
            _UserInfoCard(user: daUser, isMobile: true),
            const SizedBox(height: 16),
            _RecentActivitiesCard(isMobile: true),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMobile;

  const _ProfileHeader({required this.user, this.isMobile = false});

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
              child: Column(
                children: [
                  Text(
                    user['name'] ?? 'DA Officer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    user['position'] ?? 'Agricultural Officer',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                ],
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

class _UserInfoCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMobile;

  const _UserInfoCard({required this.user, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Employee ID', value: user['employeeId'] ?? 'N/A'),
            _InfoRow(label: 'Email', value: user['email'] ?? 'N/A'),
            _InfoRow(
                label: 'Contact Number', value: user['contactNumber'] ?? 'N/A'),
            _InfoRow(
                label: 'Department',
                value: user['department'] ?? 'Department of Agriculture'),
            _InfoRow(label: 'Region Assigned', value: user['region'] ?? 'N/A'),
            _InfoRow(label: 'Date Joined', value: user['dateJoined'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final bool isMobile;

  const _RecentActivitiesCard({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                return _ActivityItem(
                  title: 'Updated farm records',
                  description: 'Added new crop yield data for Barangay 1',
                  time: '2 hours ago',
                );
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('View All Activities'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.edit,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

final daUserData = {
  'name': 'Maria Santos',
  'position': 'Senior Agricultural Officer',
  'employeeId': 'DA-2023-0456',
  'email': 'maria.santos@da.gov.ph',
  'contactNumber': '09123456789',
  'department': 'Department of Agriculture',
  'region': 'Region IV-A',
  'dateJoined': 'March 15, 2018',
};
