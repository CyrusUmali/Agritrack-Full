import 'package:flutter/material.dart';
import '../polygon_manager.dart';

class FarmsList {
  static Widget build({
    required PolygonData barangay,
    required List<PolygonData> farms,
    required ThemeData theme,
    required PolygonManager polygonManager,
    required BuildContext modalContext, // Add this parameter
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                // Find the original index in the polygonManager's polygons list
                final originalIndex = polygonManager.polygons.indexOf(farm);

                return ListTile(
                  leading: Icon(
                    Icons.agriculture,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(farm.name),
                  subtitle: Text(farm.pinStyle.toString().split('.').last),
                  tileColor:
                      polygonManager.selectedPolygonIndex == originalIndex
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : null,
                  onTap: () {
                    final overlayContext =
                        Navigator.of(context, rootNavigator: true).context;

                    polygonManager.selectPolygon(
                      originalIndex,
                      context: overlayContext,
                    );

                    // polygonManager.selectPolygon(
                    //   originalIndex,
                    //   context: context,
                    // );

                    // print('printhere');

                    // print(context);

                    // Close the modal
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
