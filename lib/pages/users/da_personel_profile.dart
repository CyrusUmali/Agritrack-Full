import 'package:flareline/pages/users/DAProfile/profile_header.dart';
import 'package:flareline/pages/users/DAProfile/profile_info_card.dart';
import 'package:flareline/pages/users/DAProfile/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DAOfficerProfile extends LayoutWidget {
  final Map<String, dynamic> daUser;

  const DAOfficerProfile({super.key, required this.daUser});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Profile';
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

    print("a");
    print(daUser);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(user: daUser),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: UserInfoCard(user: daUser),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: StatsCard(user: daUser),
                  ),
                ],
              ),
            ],
          ),
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
            ProfileHeader(user: daUser, isMobile: true),
            const SizedBox(height: 16),
            UserInfoCard(user: daUser, isMobile: true),
            const SizedBox(height: 16),
            StatsCard(user: daUser, isMobile: true),
          ],
        ),
      ),
    );
  }
}
