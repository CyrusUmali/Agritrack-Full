import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SectorsGridCard extends StatelessWidget {
  const SectorsGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: (context) => contentDesktopWidget(context),
      mobile: (context) => contentMobileWidget(context),
      tablet: (context) => contentMobileWidget(context),
    );
  }

  Widget contentDesktopWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _itemCardWidget(context, Icons.rice_bowl, '2,000 Farmers',
                '10,000 ha', '85%', true, DeviceScreenType.desktop)),
        const SizedBox(width: 14),
        Expanded(
            child: _itemCardWidget(context, Icons.agriculture, '1,500 Farmers',
                '8,500 ha', '78%', true, DeviceScreenType.desktop)),
        const SizedBox(width: 16),
        Expanded(
            child: _itemCardWidget(context, Icons.pets, '800 Farmers', 'N/A',
                '90%', true, DeviceScreenType.desktop)),
        const SizedBox(width: 16),
        Expanded(
            child: _itemCardWidget(context, Icons.eco, '600 Farmers',
                '5,200 ha', '88%', true, DeviceScreenType.desktop)),
        const SizedBox(width: 16),
        Expanded(
            child: _itemCardWidget(context, Icons.set_meal, '1,200 Farmers',
                '15,000 ha', '82%', true, DeviceScreenType.desktop)),
        const SizedBox(width: 16),
        Expanded(
            child: _itemCardWidget(context, Icons.grass, '900 Farmers',
                '7,300 ha', '87%', true, DeviceScreenType.desktop)),
      ],
    );
  }

  Widget contentMobileWidget(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Prevents internal scrolling
      crossAxisCount: 2, // Ensures two columns
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0, // Adjust the aspect ratio to fit content
      children: [
        _itemCardWidget(context, Icons.rice_bowl, '2,000 Farmers', '10,000 ha',
            '85%', true, DeviceScreenType.mobile),
        _itemCardWidget(context, Icons.agriculture, '1,500 Farmers', '8,500 ha',
            '78%', true, DeviceScreenType.mobile),
        _itemCardWidget(context, Icons.pets, '800 Farmers', 'N/A', '90%', true,
            DeviceScreenType.mobile),
        _itemCardWidget(context, Icons.eco, '600 Farmers', '5,200 ha', '88%',
            true, DeviceScreenType.mobile),
        _itemCardWidget(context, Icons.set_meal, '1,200 Farmers', '15,000 ha',
            '82%', true, DeviceScreenType.mobile),
        _itemCardWidget(context, Icons.grass, '900 Farmers', '7,300 ha', '87%',
            true, DeviceScreenType.mobile),
      ],
    );
  }

  _itemCardWidget(
      BuildContext context,
      IconData icon,
      String farmers,
      String landCovered,
      String performance,
      bool isGrow,
      DeviceScreenType screenType) {
    double farmersTextSize = screenType == DeviceScreenType.desktop ? 12 : 7;
    double landCoveredTextSize =
        screenType == DeviceScreenType.desktop ? 12 : 10;
    double performanceTextSize =
        screenType == DeviceScreenType.desktop ? 12 : 10;

    return CommonCard(
      height: 180, // Increased height to prevent overflow
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 0, vertical: 6), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Icon(
                  icon,
                  color: GlobalColors.sideBar,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              farmers,
              style: TextStyle(
                  fontSize: farmersTextSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (landCovered.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                landCovered,
                style: TextStyle(
                    fontSize: landCoveredTextSize, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Production:",
                  style: TextStyle(
                      fontSize: performanceTextSize, color: Colors.green),
                  softWrap: true, // Ensures wrapping
                  overflow: TextOverflow.visible, // Allows expansion
                ),
                const Spacer(),
                Text(
                  performance,
                  style: TextStyle(
                    fontSize: performanceTextSize,
                    color: isGrow ? Colors.green : Colors.lightBlue,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  isGrow ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isGrow ? Colors.green : Colors.lightBlue,
                  size: 12,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
