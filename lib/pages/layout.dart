import 'package:flareline/pages/flareline_layout.dart';
import 'package:flareline/pages/toolbar.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class LayoutWidget extends FlarelineLayoutWidget {
  const LayoutWidget({super.key});

  @override
  String sideBarAsset(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.user?.role ?? 'guest';

    // Optional: fall back to English if localization still matters
    // final lang = context.watch<LocalizationProvider>().languageCode;

    // Example: assets/routes/menu_route_admin.json
    return 'assets/routes/menu_route_$role.json';
  }

  @override
  Widget? toolbarWidget(BuildContext context, bool showDrawer) {
    return ToolBarWidget(
      showMore: showDrawer,
      showChangeTheme: true,
      userInfoWidget: _userInfoWidget(context),
    );
  }

  Widget _userInfoWidget(BuildContext context) {
    return const Row(
      children: [
        Column(
          children: [
            // Text('Demo'),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        CircleAvatar(
          backgroundImage: AssetImage('assets/user/user-01.png'),
          radius: 22,
        )
      ],
    );
  }
}
