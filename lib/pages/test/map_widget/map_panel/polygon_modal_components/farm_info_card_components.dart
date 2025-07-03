import 'package:flareline/core/models/farmer_model.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';

import 'farm_info_card_dialogs.dart';

class FarmInfoCardComponents {
  static Widget buildEditableFarmNameRow({
    required BuildContext context,
    required String currentName,
    required Function(String) onNameChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final TextEditingController controller =
        TextEditingController(text: currentName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.agriculture_outlined,
              size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Farm Name', style: _buildLabelStyle(theme)),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: UnderlineInputBorder(),
                    hintText: 'Enter Farm Name',
                  ),
                  onChanged: onNameChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEditableFarmOwnerRow({
    required BuildContext context,
    required String currentOwner,
    required List<Farmer> ownerOptions,
    required Function(String) onOwnerChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_outline,
              size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Farm Owner', style: _buildLabelStyle(theme)),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () {
                    FarmInfoCardDialogs.showFarmOwnerSelectionDialog(
                      context: context,
                      currentOwner: currentOwner,
                      ownerOptions: ownerOptions,
                      onOwnerChanged: onOwnerChanged,
                      theme: theme,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        currentOwner,
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

  static Widget buildEditableBarangayRow({
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
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () {
                    FarmInfoCardDialogs.showBarangaySelectionDialog(
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

  static Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _buildLabelStyle(theme)),
                const SizedBox(height: 2),
                Text(value, style: _buildValueStyle(theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyState(String message, ThemeData theme) {
    return Text(
      message,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  static TextStyle _buildLabelStyle(ThemeData theme) {
    return theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(fontWeight: FontWeight.bold);
  }

  static TextStyle _buildValueStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium ?? const TextStyle();
  }
}
