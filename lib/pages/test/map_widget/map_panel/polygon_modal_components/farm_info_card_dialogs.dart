import 'package:flareline/core/models/farmer_model.dart';
import 'package:flutter/material.dart';

class FarmInfoCardDialogs {
  static void showFarmNameEditDialog({
    required BuildContext context,
    required String currentName,
    required Function(String) onNameChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final textController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Farm Name',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter farm name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = textController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  onNameChanged(newName);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  static void showFarmOwnerSelectionDialog({
    required BuildContext context,
    required String currentOwner, // Expects string in "id: name" format
    required List<Farmer> ownerOptions,
    required Function(String)
        onOwnerChanged, // Returns string in "id: name" format
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    String searchQuery = '';
    String selectedOwner = currentOwner;

    // Helper function to create the display string
    String _ownerDisplayString(Farmer farmer) => '${farmer.id}: ${farmer.name}';

    // Find initial selected farmer
    Farmer? _findSelectedFarmer() {
      return ownerOptions.firstWhere(
        (owner) => _ownerDisplayString(owner) == selectedOwner,
        orElse: () => ownerOptions.first, // fallback to first if not found
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width > 600;
            final currentFarmer = _findSelectedFarmer();

            return AlertDialog(
              title: Text('Select Farm Owner',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  )),
              content: SizedBox(
                width: isDesktop ? 500 : double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search farm owners...',
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
                      height: isDesktop ? 400 : 200,
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        child: ListView.builder(
                          itemCount: ownerOptions
                              .where((owner) => _ownerDisplayString(owner)
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .length,
                          itemBuilder: (context, index) {
                            final owner = ownerOptions
                                .where((owner) => _ownerDisplayString(owner)
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()))
                                .elementAt(index);
                            final ownerString = _ownerDisplayString(owner);

                            return ListTile(
                              title: Text(ownerString),
                              leading: Radio<String>(
                                value: ownerString,
                                groupValue: selectedOwner,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedOwner = value ?? selectedOwner;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  selectedOwner = ownerString;
                                });
                              },
                              tileColor: selectedOwner == ownerString
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
                    if (selectedOwner != currentOwner) {
                      onOwnerChanged(selectedOwner);
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

  static void showBarangaySelectionDialog({
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
            final isDesktop = MediaQuery.of(context).size.width > 600;

            return AlertDialog(
              title: Text('Select Barangay',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  )),
              content: SizedBox(
                width: isDesktop ? 500 : double.maxFinite,
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
                      height: isDesktop ? 400 : 200,
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
