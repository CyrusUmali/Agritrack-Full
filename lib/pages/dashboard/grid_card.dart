// ignore_for_file: unnecessary_string_escapes

import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/dashboard/analytics_widget.dart'; // Import AnalyticsWidget

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

  Widget contentMobileWidget(BuildContext context) {
    return Column(
      children: [
        _itemCardWidget(
            context, Icons.data_object, '\1,200 acres', 'Total Land Area', ' '),
        const SizedBox(
          height: 16,
        ),
        _itemCardWidget(
            context, Icons.shopping_cart, '\12 Types', 'Total Products', ' '),
        const SizedBox(
          height: 16,
        ),
        _itemCardWidget(context, Icons.group, '2.450', 'Annual Yield', ' '),
        const SizedBox(
          height: 16,
        ),
        _itemCardWidget(
            context, Icons.security_rounded, '3.456', 'Total Farmers', ' '),
        const SizedBox(
          height: 16,
        ),
        const AnalyticsWidget(),
      ],
    );
  }

  Widget contentDesktopWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _itemCardWidget(context, Icons.data_object, '\1,200 acres',
                  'Total Land Area', ' '),
              _itemCardWidget(context, Icons.shopping_cart, '\12 Types',
                  'Total Products', ' '),
              _itemCardWidget(
                  context, Icons.group, '2.450', 'Annual Yield', ' '),
              _itemCardWidget(context, Icons.security_rounded, '3.456',
                  'Total Farmers', ' '),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(
          flex: 2,
          child: AnalyticsWidget(),
        ),
      ],
    );
  }

  _itemCardWidget(BuildContext context, IconData icons, String text,
      String subTitle, String percentText) {
    return CommonCard(
      height: 100,
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Icon(
                  icons,
                  color: GlobalColors.sideBar,
                  size: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              children: [
                Text(
                  subTitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
