import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:latlong2/latlong.dart';

import '../../pin_style.dart';
import '../../polygon_manager.dart';

class EditControls {
  static Widget build({
    required BuildContext context,
    required PolygonData polygon,
    required PinStyle selectedPinStyle, // Add this parameter
    required TextEditingController latController,
    required TextEditingController lngController,
    required Color selectedColor,
    required Function(Color) onColorChanged,
    required Function(PinStyle) onPinStyleChanged,
    required Function(LatLng) onCenterChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            Text('Edit Farm',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                )),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),

            // Color picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.color_lens,
                  color: colorScheme.onSurface.withOpacity(0.8)),
              title: Text('Polygon Color', style: textTheme.bodyMedium),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
              ),
              onTap: () => _showColorPicker(
                  context, selectedColor, onColorChanged, theme),
            ),

            // Coordinate inputs
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      onChanged: (value) {
                        final lat = double.tryParse(value);
                        if (lat != null) {
                          onCenterChanged(
                              LatLng(lat, polygon.center.longitude));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: lngController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      onChanged: (value) {
                        final lng = double.tryParse(value);
                        if (lng != null) {
                          onCenterChanged(LatLng(polygon.center.latitude, lng));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Pin style dropdown
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.layers,
                  color: colorScheme.onSurface.withOpacity(0.8)),
              title: Text('Sector', style: textTheme.bodyMedium),
              trailing: DropdownButton<PinStyle>(
                value: selectedPinStyle,
                onChanged: (newStyle) {
                  if (newStyle != null) {
                    onPinStyleChanged(newStyle);
                  }
                },
                style: textTheme.bodyMedium,
                dropdownColor: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                underline: Container(),
                items: PinStyle.values.map((style) {
                  return DropdownMenuItem<PinStyle>(
                    value: style,
                    child: Text(
                      style.toString().split('.').last,
                      style: textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showColorPicker(
    BuildContext context,
    Color initialColor,
    Function(Color) onColorChanged,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Color',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  )),
              const SizedBox(height: 16),
              ColorPicker(
                pickerColor: initialColor,
                onColorChanged: onColorChanged,
                displayThumbColor: true,
                enableAlpha: false,
                portraitOnly: true,
                pickerAreaHeightPercent: 0.5,
                pickerAreaBorderRadius: BorderRadius.circular(12),
                hexInputBar: false,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
