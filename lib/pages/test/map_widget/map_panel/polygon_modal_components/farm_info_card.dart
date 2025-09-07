import 'dart:convert';

import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flareline/services/lanugage_extension.dart';
import 'package:flutter/services.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flareline/services/lanugage_extension.dart';
import 'farm_info_card_components.dart';

class FarmInfoCard {
  static List<String> _barangays = [];

  static Future<void> loadBarangays() async {
    try {
      final jsonString = await rootBundle.loadString('assets/barangays.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      _barangays = List<String>.from(jsonData['barangays'] ?? []);
    } catch (e) {
      debugPrint('Error loading barangays: $e');
      _barangays = [];
    }
  }

  static Widget build({
    required BuildContext context,
    required PolygonData polygon,
    required ThemeData theme,
    required List<Product> products,
    required List<Farmer> farmers,
    required Function(String) onBarangayChanged,
    required Function(String) onFarmOwnerChanged,
    required Function(String) onFarmNameChanged,
    required Function(PolygonData) onFarmUpdated,
    required TextEditingController farmNameController, // Add this parameter
  }) {
    final colorScheme = theme.colorScheme;

    final farmName = polygon.name ?? 'Unnamed Farm';
    final farmOwner = polygon.owner ?? 'Select owner';
    final description = polygon.description;
    final location = polygon.center != null
        ? 'Lat: ${polygon.center!.latitude.toStringAsFixed(4)}, Lng: ${polygon.center!.longitude.toStringAsFixed(4)}'
        : 'Location not set';
    final barangay = polygon.parentBarangay ?? 'Select barangay';
    final products = polygon.products ?? [];

    // Get farm owner names from the passed farmers list
    final farmOwnerNames = farmers.map((farmer) => farmer.name).toList();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.translate('Farm Information'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            FarmInfoCardComponents.buildEditableFarmNameRow(
              context: context,
              controller: farmNameController, // Pass the controller
              onNameChanged: onFarmNameChanged,
              theme: theme,
            ),
            FarmInfoCardComponents.buildEditableFarmOwnerRow(
              context: context,
              currentOwner: farmOwner,
              ownerOptions: farmers,
              onOwnerChanged: onFarmOwnerChanged,
              theme: theme,
            ),
            FarmInfoCardComponents.buildEditableBarangayRow(
              context: context,
              currentBarangay: barangay,
              barangayOptions: _barangays,
              onBarangayChanged: onBarangayChanged,
              theme: theme,
            ),
            FarmInfoCardComponents.buildInfoRow(
              icon: Icons.area_chart,
              label: 'Area',
              value: polygon.area != null ? '${polygon.area} Ha' : 'N/A',
              theme: theme,
            ),
            FarmInfoCardComponents.buildInfoRow(
              icon: Icons.location_on,
              label: 'Location',
              value: location,
              theme: theme,
            ),
            if (description != null && description.isNotEmpty)
              FarmInfoCardComponents.buildInfoRow(
                icon: Icons.description,
                label: 'Description',
                value: description,
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}
