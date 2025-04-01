// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../polygon_manager.dart';

class FarmInfoCard {
  static List<String> _barangays = []; // This will hold our barangay list

  // Load barangays from JSON file
  static Future<void> loadBarangays() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/barangays.json');
      final jsonData = json.decode(jsonString);
      _barangays = List<String>.from(jsonData['barangays']);
    } catch (e) {
      print('Error loading barangays: $e');
      _barangays = []; // Fallback to empty list
    }
  }

  static Widget build({
    required BuildContext context,
    required PolygonData polygon,
    required ThemeData theme,
    required Function(String) onBarangayChanged,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final farmDetails = {
      'name': polygon.name,
      'area': 'N/A hectares',
      'crop': polygon.pinStyle.toString().split('.').last,
      'status': 'Active',
      'description': polygon.description ?? 'No description',
      'location': 'Lat: ${polygon.center.latitude.toStringAsFixed(4)}, '
          'Lng: ${polygon.center.longitude.toStringAsFixed(4)}',
      'products': _getFarmProducts().join(', '),
      'barangay': polygon.parentBarangay ?? 'Select barangay',
    };

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
            Text('Farm Information',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                )),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.agriculture_outlined, 'Farm Name',
                farmDetails['name']!, theme),
            _buildEditableBarangayRow(
              context: context,
              currentBarangay: farmDetails['barangay']!,
              barangayOptions: _barangays,
              onBarangayChanged: onBarangayChanged,
              theme: theme,
            ),
            _buildInfoRow(
                Icons.crop_square, 'Crop', farmDetails['crop']!, theme),
            _buildInfoRow(
                Icons.area_chart, 'Area', farmDetails['area']!, theme),
            _buildInfoRow(
                Icons.location_on, 'Location', farmDetails['location']!, theme),
            _buildInfoRow(Icons.shopping_basket, 'Products',
                farmDetails['products']!, theme),
            if (farmDetails['description']!.isNotEmpty)
              _buildInfoRow(Icons.description, 'Description',
                  farmDetails['description']!, theme),
          ],
        ),
      ),
    );
  }

  static List<String> _getFarmProducts() {
    return const ["Tilapia", "Bangus", "Shrimp"];
  }

  static Widget _buildInfoRow(
      IconData icon, String label, String value, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEditableBarangayRow({
    required BuildContext context,
    required String currentBarangay,
    required List<String> barangayOptions,
    required Function(String) onBarangayChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_city,
              size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barangay',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    )),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () {
                    _showBarangaySelectionDialog(
                      context: context,
                      currentBarangay: currentBarangay,
                      barangayOptions: barangayOptions,
                      onBarangayChanged: onBarangayChanged,
                      theme: theme,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        currentBarangay,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down,
                          size: 20, color: colorScheme.onSurface),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showBarangaySelectionDialog({
    required BuildContext context,
    required String currentBarangay,
    required List<String> barangayOptions,
    required Function(String) onBarangayChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    String searchQuery = '';
    String selectedBarangay = currentBarangay;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Determine if we're on a larger screen
            final isDesktop = MediaQuery.of(context).size.width > 600;

            return AlertDialog(
              title: Text('Select Barangay',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  )),
              content: SizedBox(
                width: isDesktop ? 500 : double.maxFinite, // Wider on desktop
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search barangays...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: isDesktop ? 400 : 200, // Taller on desktop
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        child: ListView.builder(
                          itemCount: barangayOptions
                              .where((barangay) => barangay
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .length,
                          itemBuilder: (context, index) {
                            final barangay = barangayOptions
                                .where((barangay) => barangay
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()))
                                .elementAt(index);

                            return ListTile(
                              title: Text(barangay),
                              leading: Radio<String>(
                                value: barangay,
                                groupValue: selectedBarangay,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedBarangay =
                                        value ?? selectedBarangay;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  selectedBarangay = barangay;
                                });
                              },
                              tileColor: selectedBarangay == barangay
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedBarangay != currentBarangay) {
                      onBarangayChanged(selectedBarangay);
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
