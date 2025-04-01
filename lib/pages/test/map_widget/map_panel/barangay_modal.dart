import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../polygon_manager.dart';
import 'barangay_info_card.dart';
import 'farms_list.dart';
import 'barangay_stats.dart';

class BarangayModal {
  static Future<void> show({
    required BuildContext context,
    required PolygonData barangay,
    required List<PolygonData> farms,
    required PolygonManager polygonManager,
  }) async {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (isLargeScreen) {
      await _showLargeScreenModal(
        context: context,
        barangay: barangay,
        farms: farms,
        theme: theme,
        polygonManager: polygonManager,
      );
    } else {
      await _showSmallScreenModal(
        context: context,
        barangay: barangay,
        farms: farms,
        theme: theme,
        polygonManager: polygonManager,
      );
    }
  }

  static Future<void> _showSmallScreenModal({
    required BuildContext context,
    required PolygonData barangay,
    required List<PolygonData> farms,
    required ThemeData theme,
    required PolygonManager polygonManager,
  }) async {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasSabGradient: true,
            topBarTitle: Text(
              'Barangay Details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            isTopBarLayerAlwaysVisible: true,
            trailingNavBarWidget: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with barangay name
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      barangay.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Barangay info card
                  BarangayInfoCard.build(barangay: barangay, theme: theme),

                  const SizedBox(height: 16),

                  // Barangay statistics
                  BarangayStats.build(
                      barangay: barangay, farms: farms, theme: theme),

                  const SizedBox(height: 16),

                  // Farms list
                  FarmsList.build(
                      barangay: barangay,
                      farms: farms,
                      theme: theme,
                      polygonManager: polygonManager,
                      modalContext: modalContext),
                ],
              ),
            ),
          )
        ];
      },
      modalTypeBuilder: (context) => const WoltBottomSheetType(),
      onModalDismissedWithBarrierTap: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> _showLargeScreenModal({
    required BuildContext context,
    required PolygonData barangay,
    required List<PolygonData> farms,
    required ThemeData theme,
    required PolygonManager polygonManager,
  }) async {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        // Renamed to dialogContext for clarity
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.8,
            height: MediaQuery.of(dialogContext).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Barangay Details: ${barangay.name}',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Info and stats
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BarangayInfoCard.build(
                                  barangay: barangay, theme: theme),
                              const SizedBox(height: 24),
                              BarangayStats.build(
                                  barangay: barangay,
                                  farms: farms,
                                  theme: theme),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      // Right side - Farms list
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              FarmsList.build(
                                barangay: barangay,
                                farms: farms,
                                theme: theme,
                                polygonManager: polygonManager,
                                modalContext:
                                    dialogContext, // Use dialogContext here
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
