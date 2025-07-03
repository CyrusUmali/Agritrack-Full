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

    // Create a completely custom header
    Widget _buildHeader(BuildContext context) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Barangay Details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            backgroundColor: Colors.white,
            hasSabGradient: false,
            isTopBarLayerAlwaysVisible: false, // Disable default header
            topBarTitle: const SizedBox(), // Empty title
            trailingNavBarWidget: const SizedBox(), // Empty trailing widget
            child: Column(
              children: [
                _buildHeader(modalContext), // Add custom header
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _buildContent(
                      context: modalContext,
                      barangay: barangay,
                      farms: farms,
                      theme: theme,
                      polygonManager: polygonManager,
                    ),
                  ),
                ),
              ],
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
    final textTheme = theme.textTheme;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: EdgeInsets.zero,
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
        // Header with barangay name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            barangay.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

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
