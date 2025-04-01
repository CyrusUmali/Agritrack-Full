// ignore_for_file: unnecessary_string_escapes

import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';

class SectorsGridCard extends StatelessWidget {
  const SectorsGridCard({super.key});

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
                '\Farmers',
                "Active:", // Subtitle 1
                '0.43%',
                true,
                "Inactive: ", // Subtitle 2
                '123',
                '213')), // Number value for Subtitle 1
        const SizedBox(
          width: 16,
        ),
        Expanded(
            child: _itemCardWidget(
                context,
                Icons.shopping_cart,
                '\Annual Production',
                'Produce: ', // Subtitle 1
                '0.43%',
                true,
                "", // Subtitle 2
                '10,000 tons',
                '')), // Number value for Subtitle 1
        const SizedBox(
          width: 16,
        ),
        Expanded(
            child: _itemCardWidget(
                context,
                Icons.group,
                'Landarea',
                AppLocalizations.of(context)!.totalProduct, // Subtitle 1
                '0.43%',
                true,
                "  ", // Subtitle 2
                ' ',
                '')), // Number value for Subtitle 1
        const SizedBox(
          width: 16,
        ),
        Expanded(
            child: _itemCardWidget(
                context,
                Icons.security_rounded,
                'Registration',
                'Registered: ', // Subtitle 1
                '0.43%',
                false,
                "Not Registered: ", // Subtitle 2
                '101',
                '12')), // Number value for Subtitle 1
      ],
    );
  }

  Widget contentMobileWidget(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Make the content scroll horizontally
      child: Row(
        children: [
          Container(
            width: 240, // Set a fixed width for all cards
            child: _itemCardWidget(
                context,
                Icons.data_object,
                'Farmers',
                "Active:", // Subtitle 1
                '0.43%',
                true,
                "Inactive: ", // Subtitle 2
                '123',
                '213'), // Number value for Subtitle 1
          ),
          const SizedBox(
            width: 16, // Horizontal spacing between cards
          ),
          Container(
            width: 240, // Set a fixed width for all cards
            child: _itemCardWidget(
                context,
                Icons.shopping_cart,
                'Annual Production',
                'Produce: ', // Subtitle 1
                '0.43%',
                true,
                "", // Subtitle 2
                '10,000 tons',
                ''), // Number value for Subtitle 1
          ),
          const SizedBox(
            width: 16, // Horizontal spacing between cards
          ),
          Container(
            width: 240, // Set a fixed width for all cards
            child: _itemCardWidget(
                context,
                Icons.group,
                'Landarea',
                AppLocalizations.of(context)!.totalProduct, // Subtitle 1
                '0.43%',
                true,
                "  ", // Subtitle 2
                ' ',
                ''), // Number value for Subtitle 1
          ),
          const SizedBox(
            width: 16, // Horizontal spacing between cards
          ),
          Container(
            width: 240, // Set a fixed width for all cards
            child: _itemCardWidget(
                context,
                Icons.security_rounded,
                'Registration',
                'Registered: ', // Subtitle 1
                '0.43%',
                false,
                "Not Registered: ", // Subtitle 2
                '101',
                '12'), // Number value for Subtitle 1
          ),
        ],
      ),
    );
  }

  _itemCardWidget(
    BuildContext context,
    IconData icons,
    String text,
    String subTitle1,
    String percentText,
    bool isGrow,
    String subTitle2,
    String subTitle1Value,
    String subTitle2Value,
  ) {
    return CommonCard(
      height: 166,
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
            const SizedBox(
              height: 12,
            ),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 6,
            ),
            // Subtitle 1 with its value in a Row
            Row(
              children: [
                Text(
                  subTitle1,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 4), // Spacing between subtitle and value
                Text(
                  subTitle1Value,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            // Subtitle 2 with its value in a Row
            Row(
              children: [
                Text(
                  subTitle2,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 4), // Spacing between subtitle and value
                Text(
                  subTitle2Value, // Placeholder for Subtitle 2 value (you can add a parameter if needed)
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
          ],
        ),
      ),
    );
  }
}
