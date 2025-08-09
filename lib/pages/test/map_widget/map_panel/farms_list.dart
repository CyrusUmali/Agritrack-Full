import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter/material.dart';
import '../polygon_manager.dart'; 

class FarmsList {
  static Widget build({
    required PolygonData barangay,
    required List<PolygonData> farms,
    required ThemeData theme,
    required PolygonManager polygonManager,
    required BuildContext modalContext, required ValueKey<String> key,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Farms in ${barangay.name}',
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (farms.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No farms found in this barangay'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: farms.length,
              itemBuilder: (context, index) {
                final farm = farms[index];
                final originalIndex = polygonManager.polygons.indexOf(farm);

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: getPinColor(farm.pinStyle),
                      shape: BoxShape.circle,
                    ),
                    child: getPinIcon(farm.pinStyle),
                  ),
                  title: Text(farm.name),
                  subtitle: Text(
  farm.owner ?? 'Unknown Owner',
  style: TextStyle(fontSize: 12), // Adjust the font size as needed
),
                  tileColor: polygonManager.selectedPolygonIndex == originalIndex
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : null,
                  onTap: () {
                    final overlayContext =
                        Navigator.of(context, rootNavigator: true).context;
                    polygonManager.selectPolygon(
                      originalIndex,
                      context: overlayContext,
                    );
                    Navigator.of(modalContext).pop();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}