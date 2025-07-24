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
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Theme.of(context).cardTheme.color,
          hasSabGradient: false,
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: Container(
            color: Theme.of(context).cardTheme.color,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed: () => Navigator.of(modalContext).pop(),
                ),
              ],
            ),
          ),
          child: Container(
            color: Theme.of(context).cardTheme.color,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(
                context: modalContext,
                barangay: barangay,
                farms: farms,
                theme: theme,
                polygonManager: polygonManager,
              ),
            ),
          ),
        )
      ],
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
    final textTheme = theme.textTheme;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).cardTheme.color,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.6,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildContent(
                      context: dialogContext,
                      barangay: barangay,
                      farms: farms,
                      theme: theme,
                      polygonManager: polygonManager,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildContent({
    required BuildContext context,
    required PolygonData barangay,
    required List<PolygonData> farms,
    required ThemeData theme,
    required PolygonManager polygonManager,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barangay info card
        BarangayInfoCard.build(
            barangay: barangay, theme: theme, context: context),

        const SizedBox(height: 16),

        // Barangay statistics
        BarangayStats.build(barangay: barangay, farms: farms, theme: theme),

        const SizedBox(height: 16),

        // Farms list
        FarmsList.build(
          barangay: barangay,
          farms: farms,
          theme: theme,
          polygonManager: polygonManager,
          modalContext: context,
        ),
      ],
    );
  }
}
