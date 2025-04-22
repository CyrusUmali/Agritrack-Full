import 'package:flareline/pages/recommendation/requirement.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequirementPage extends LayoutWidget {
  const RequirementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Crop Requirements';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const CropRequirementsWidget();
  }

  @override
  Widget buildContent(BuildContext context) {
    return const CropRequirementsWidget();
  }
}
