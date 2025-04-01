import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';

class FarmCreationModal {
  static Future<bool> show({
    required BuildContext context,
    required PolygonData polygon,
    required Function(String) onNameChanged,
  }) async {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (isLargeScreen) {
      return await _showLargeScreenModal(
        context: context,
        polygon: polygon,
        onNameChanged: onNameChanged,
        theme: theme,
      );
    } else {
      return await _showSmallScreenModal(
        context: context,
        polygon: polygon,
        onNameChanged: onNameChanged,
        theme: theme,
      );
    }
  }

  static Future<bool> _showSmallScreenModal({
    required BuildContext context,
    required PolygonData polygon,
    required Function(String) onNameChanged,
    required ThemeData theme,
  }) async {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final nameController = TextEditingController(text: polygon.name);

    return await WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasSabGradient: true,
            topBarTitle: Text(
              'Create New Farm',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            isTopBarLayerAlwaysVisible: true,
            trailingNavBarWidget: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(modalContext).pop(false),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Farm Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Ensures UI updates
                          onNameChanged(value);
                        },
                      ),
                      // Add some spacing below the field
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
            stickyActionBar: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(modalContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        onNameChanged(nameController.text);
                        Navigator.of(modalContext).pop(true);
                      },
                      child: const Text('Create Farm'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ];
      },
      modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
      onModalDismissedWithBarrierTap: () => Navigator.of(context).pop(false),
    );
  }

  static Future<bool> _showLargeScreenModal({
    required BuildContext context,
    required PolygonData polygon,
    required Function(String) onNameChanged,
    required ThemeData theme,
  }) async {
    final nameController = TextEditingController(text: polygon.name);

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create New Farm',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Farm Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: onNameChanged,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              onNameChanged(nameController.text);
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Create Farm'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }
}
