// ignore_for_file: unnecessary_string_escapes

import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/dashboard/analytics_widget.dart';

class GridCard extends StatelessWidget {
  const GridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: contentDesktopWidget,
      mobile: contentMobileWidget,
      tablet: contentMobileWidget,
    );
  }

  Widget contentDesktopWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.data_object,
            'Total Land Area',
            'Size:',
            '',
            true,
            'Plots:',
            '1,200 acres',
            '24',
            DeviceScreenType.desktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.shopping_cart,
            'Total Products',
            'Types:',
            '',
            true,
            'Varieties:',
            '12',
            '48',
            DeviceScreenType.desktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.group,
            'Annual Yield',
            'Volume:',
            '',
            true,
            'Value:',
            '2,450 tons',
            '\$1.2M',
            DeviceScreenType.desktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.security_rounded,
            'Total Farmers',
            'Active:',
            '',
            false,
            'Inactive:',
            '3,456',
            '124',
            DeviceScreenType.desktop,
          ),
        ),
      ],
    );
  }

  Widget contentMobileWidget(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _itemCardWidget(
              context,
              Icons.data_object,
              'Total Land Area',
              'Size:',
              '',
              true,
              'Plots:',
              '1,200 acres',
              '24',
              DeviceScreenType.mobile,
            ),
            _itemCardWidget(
              context,
              Icons.shopping_cart,
              'Total Products',
              'Types:',
              '',
              true,
              'Varieties:',
              '12',
              '48',
              DeviceScreenType.mobile,
            ),
            _itemCardWidget(
              context,
              Icons.group,
              'Annual Yield',
              'Volume:',
              '',
              true,
              'Value:',
              '2,450 tons',
              '\$1.2M',
              DeviceScreenType.mobile,
            ),
            _itemCardWidget(
              context,
              Icons.security_rounded,
              'Total Farmers',
              'Active:',
              '',
              false,
              'Inactive:',
              '3,456',
              '124',
              DeviceScreenType.mobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _itemCardWidget(
    BuildContext context,
    IconData icons,
    String title,
    String subTitle1,
    String percentText,
    bool isGrow,
    String subTitle2,
    String subTitle1Value,
    String subTitle2Value,
    DeviceScreenType screenType,
  ) {
    double titleSize = screenType == DeviceScreenType.desktop ? 18 : 14;
    double subtitleSize = screenType == DeviceScreenType.desktop ? 10 : 8;

    return CommonCard(
      height: screenType == DeviceScreenType.desktop ? 166 : 140,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Icon(
                  icons,
                  color: GlobalColors.sideBar,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  subTitle1,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  subTitle1Value,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  subTitle2,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  subTitle2Value,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
