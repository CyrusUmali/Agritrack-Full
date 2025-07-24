import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/yields/yield_profile/yield_profile_form.dart';
import 'package:flareline/pages/yields/yield_profile/yield_profile_header.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

class YieldProfile extends LayoutWidget {
  const YieldProfile({super.key, required this.yieldData});

  final Yield yieldData;

  @override
  String breakTabTitle(BuildContext context) {
    return "";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YieldProfileHeader(yieldData: yieldData),
            YieldProfileForm(yieldData: yieldData),
          ],
        ),
      ),
    );
  }
}
