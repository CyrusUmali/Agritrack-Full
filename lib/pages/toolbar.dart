library flareline_uikit;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/farmers/farmer_profile.dart';
import 'package:flareline/pages/users/da_personel_profile.dart';
import 'package:flareline/pages/users/farmer_registration.dart';
import 'package:flareline/pages/users/settings/settings_page.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline_uikit/service/sidebar_provider.dart';
import 'package:flareline_uikit/service/year_picker_provider.dart';
import 'package:flareline_uikit/service/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ToolBarWidget extends StatelessWidget {
  final bool? showMore;
  final bool? showChangeTheme;
  final Widget? userInfoWidget;

  const ToolBarWidget({
    super.key,
    this.showMore,
    this.showChangeTheme,
    this.userInfoWidget,
  });

  @override
  Widget build(BuildContext context) {
    return _toolsBarWidget(context);
  }

  Widget _toolsBarWidget(BuildContext context) {
    final sidebarProvider =
        Provider.of<SidebarProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        ResponsiveBuilder(
          builder: (context, sizingInformation) {
            final showMoreButton = (showMore ?? false) ||
                sizingInformation.deviceScreenType != DeviceScreenType.desktop;

            // Automatically pin the sidebar when the more button is shown
            if (showMoreButton) {
              final provider =
                  Provider.of<SidebarProvider>(context, listen: false);
              if (!provider.isPinned) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.togglePin(); // Ensure sidebar is pinned
                });
              }
            }

            return Row(
              children: [
                if (!showMoreButton) // Show toggle button when not showing more button
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1),
                        color: Colors.transparent,
                      ),
                      child: Icon(
                        Icons.menu,
                      ),
                    ),
                    onTap: () {
                      final provider =
                          Provider.of<SidebarProvider>(context, listen: false);
                      provider.togglePin();
                      if (kDebugMode) {}
                    },
                  ),
                if (showMoreButton) // Show more button when appropriate
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: const Icon(Icons.more_vert),
                    ),
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
              ],
            );
          },
        ),

        const Spacer(),

        // Year Picker with toggle-like styling
        const YearPickerWidget(),

        const SizedBox(width: 10),

        // Theme toggle
        if (showChangeTheme ?? false)
          ToggleWidget(themeProvider: themeProvider),

        const SizedBox(width: 10),

        // User info
        if (userInfoWidget != null) userInfoWidget!,

        // User menu dropdown
        InkWell(
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            child: const Icon(Icons.arrow_drop_down),
          ),
          onTap: () async {
            await showMenu(
              color: Theme.of(context).cardTheme.color,
              context: context,
              position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 100, 80, 0, 0),
              items: <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: const Text('My Profile'),
                  onTap: () => _handleProfileNavigation(context),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: const Text('Settings'),
                  onTap: () => _handleSettingsNavigation(context),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: const Text('Log out'),
                  onTap: () => onLogoutClick(context),
                ),
              ],
            );
          },
        ),
      ]),
    );
  }

  void _handleSettingsNavigation(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(daUser: user.toMap()),
      ),
    );
  }

  void _handleProfileNavigation(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    print('user:');
    print(user);

    if (user == null) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }

    final role = user.role.toLowerCase();
    final status = user.status?.toLowerCase() ?? '';

    if (role.contains('farmer')) {
      if (status.contains('pending')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FarmerRegistrationPage(farmerData: user.toMap()),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmersProfile(farmerID: user.id),
          ),
        );
      }
    } else if (role.contains('officer') || role.contains('admin')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DAOfficerProfile(daUser: user.toMap()),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DAOfficerProfile(daUser: user.toMap()),
        ),
      );
    }
  }

  void onProfileClick(BuildContext context) {
    Navigator.of(context).pushNamed('/profile');
  }

  void onSettingClick(BuildContext context) {
    Navigator.of(context).popAndPushNamed('/settings');
  }

  void onContactClick(BuildContext context) {
    Navigator.of(context).pushNamed('/contacts');
  }

  Future<void> onLogoutClick(BuildContext context) async {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Reset theme to light mode
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.themeMode = ThemeMode.light;

    // Navigate to sign-in screen and clear all routes
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/signIn',
      (Route<dynamic> route) => false,
    );
  }
}

class YearPickerWidget extends StatelessWidget {
  const YearPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearPickerProvider>(context);

    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? GlobalColors.darkerCardColor
              : FlarelineColors.background,
          borderRadius: BorderRadius.circular(45),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Theme.of(context).cardTheme.color,
              child: Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              yearProvider.selectedYear.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : null,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : null,
            ),
          ],
        ),
      ),
      onTap: () => _showYearPicker(context),
    );
  }

  void _showYearPicker(BuildContext context) {
    final yearProvider =
        Provider.of<YearPickerProvider>(context, listen: false);
    final currentYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              onPrimary: Colors.white, // Text color on primary
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black, //
            ),
          ),
          child: AlertDialog(
            title: const Text('Select Year'),
            backgroundColor: Theme.of(context).cardTheme.color,
            content: SizedBox(
              width: 300,
              height: 400,
              child: YearPicker(
                firstDate: DateTime(currentYear - 20),
                lastDate: DateTime(currentYear + 10),
                initialDate: DateTime(yearProvider.selectedYear),
                selectedDate: DateTime(yearProvider.selectedYear),
                onChanged: (DateTime dateTime) {
                  yearProvider.setYear(dateTime.year);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ToggleWidget extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ToggleWidget({
    super.key,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDark;

    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? GlobalColors.darkerCardColor
              : FlarelineColors.background,
          borderRadius: BorderRadius.circular(45),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isDark ? Colors.transparent : Colors.white,
              child: SvgPicture.asset(
                'assets/toolbar/sun.svg',
                width: 18,
                height: 18,
                color: isDark
                    ? FlarelineColors.darkTextBody
                    : FlarelineColors.primary,
              ),
            ),
            CircleAvatar(
              radius: 15,
              backgroundColor: isDark ? Colors.white : Colors.transparent,
              child: SvgPicture.asset(
                'assets/toolbar/moon.svg',
                width: 18,
                height: 18,
                color: isDark ? null : FlarelineColors.darkTextBody,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        themeProvider.toggleThemeMode();
      },
    );
  }
}
