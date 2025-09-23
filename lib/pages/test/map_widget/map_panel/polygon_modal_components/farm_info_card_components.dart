import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flareline/services/lanugage_extension.dart';

import 'farm_info_card_dialogs.dart';

class FarmInfoCardComponents {
  static Widget buildEditableFarmNameRow({
    required BuildContext context,
    required TextEditingController controller,
    required Function(String) onNameChanged,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                Text(context.translate('Farm Name'),
                    style: _buildLabelStyle(theme)),
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
    final isFarmer = context.read<UserProvider>().isFarmer;

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
                  onTap: isFarmer
                      ? null // Disable tap if user is farmer
                      : () {
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
                      if (!isFarmer) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down,
                            size: 20, color: colorScheme.onSurface),
                      ],
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
                Text('Barangay', style: _buildLabelStyle(theme)),
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

  static Widget buildEditableLakeRow({
    required BuildContext context,
    required String currentLake,
    required List<String> lakeOptions,
    required Function(String) onLakeChanged,
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
                Text('Lake', style: _buildLabelStyle(theme)),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () {
                    FarmInfoCardDialogs.showLakeSelectionDialog(
                      context: context,
                      currentLake: currentLake,
                      lakeOptions: lakeOptions,
                      onLakeChanged: onLakeChanged,
                      theme: theme,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        currentLake,
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
