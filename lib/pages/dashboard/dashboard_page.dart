import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/pages/dashboard/analytics_widget.dart';
import 'package:flareline/pages/dashboard/channel_widget.dart';
import 'package:flareline/pages/dashboard/grid_card.dart';
import 'package:flareline/pages/dashboard/map/map_chart_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/service/year_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:provider/provider.dart';
import 'package:flareline/providers/user_provider.dart';
import 'revenue_widget.dart';

class Dashboard extends LayoutWidget {
  const Dashboard({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Home';
  }

  // Helper method to check if user has a specific role
  bool _hasRole(UserModel? user, String role) {
    return user?.role?.toLowerCase() == role.toLowerCase();
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Column(
      children: [
        Consumer<YearPickerProvider>(
          builder: (context, yearProvider, child) {
            return GridCard(selectedYear: yearProvider.selectedYear);
          },
        ),

        const SizedBox(height: 16), 

        // Show AnalyticsWidget only for admin and manager
        Consumer<YearPickerProvider>(
          builder: (context, yearProvider, child) {
            return AnalyticsWidget(selectedYear: yearProvider.selectedYear);
          },
        ),
        if (_hasRole(user, 'admin')) const SizedBox(height: 30),

        const SizedBox(height: 20),

        if (_hasRole(user, 'admin') || _hasRole(user, 'officer'))
          const RevenueWidget(),

        const SizedBox(height: 16),

        // Show ChannelWidget only for admin and analyst
        if (_hasRole(user, 'admin')) ChannelWidget(),
        if (_hasRole(user, 'admin')) const SizedBox(height: 30),

        // Only show MapChartWidget on desktop for admin
        if (MediaQuery.of(context).size.width > 600 && _hasRole(user, 'admin'))
          Consumer<YearPickerProvider>(
            builder: (context, yearProvider, child) {
              return SizedBox(
                height: 700,
                child: CommonCard(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.expand(),
                    child:
                        MapChartWidget(selectedYear: yearProvider.selectedYear),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Column(
      children: [
        Consumer<YearPickerProvider>(
          builder: (context, yearProvider, child) {
            return GridCard(selectedYear: yearProvider.selectedYear);
          },
        ),
        const SizedBox(height: 16), 
        Consumer<YearPickerProvider>(
          builder: (context, yearProvider, child) {
            return AnalyticsWidget(selectedYear: yearProvider.selectedYear);
          },
        ),
        if (_hasRole(user, 'admin')) const SizedBox(height: 30),
        const SizedBox(height: 20),
        if (_hasRole(user, 'admin') || _hasRole(user, 'officer'))
          const RevenueWidget(),
        const SizedBox(height: 16),
        if (_hasRole(user, 'admin')) ChannelWidget(),
        if (_hasRole(user, 'admin')) const SizedBox(height: 30),
      ],
    );
  }
}
