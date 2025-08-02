import 'package:flareline/providers/user_provider.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pin_style.dart';
import '../../polygon_manager.dart';

class EditControls {
  static Widget build({
    required BuildContext context,
    required PolygonData polygon,
    required PinStyle selectedPinStyle,
    required Color selectedColor,
    required Function(Color) onColorChanged,
    required Function(PinStyle) onPinStyleChanged,
    required Function() onDelete,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final _isFarmer = userProvider.isFarmer;
    final _farmerId = userProvider.farmer?.id?.toString();

    print(_isFarmer);
    print(_farmerId);
    print(polygon.farmerId);

    print(polygon.pinStyle);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.category,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'Sector Type',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            _buildPinStyleDropdown(
              context: context,
              selectedPinStyle: selectedPinStyle,
              onPinStyleChanged: onPinStyleChanged,
              onColorChanged: onColorChanged,
              theme: theme,
            ),
            const SizedBox(height: 16),

            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 16),

            // _buildDeleteButton(context, onDelete, theme),

            if (_isFarmer == false || polygon.farmerId?.toString() == _farmerId)
              _buildDeleteButton(context, onDelete, theme),
          ],
        ),
      ),
    );
  }

  static Widget _buildPinStyleDropdown({
    required BuildContext context,
    required PinStyle selectedPinStyle,
    required Function(PinStyle) onPinStyleChanged,
    required Function(Color) onColorChanged,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<PinStyle>(
        value: selectedPinStyle,
        onChanged: (newStyle) {
          if (newStyle != null) {
            onPinStyleChanged(newStyle);
            final newColor = _getColorForPinStyle(newStyle);
            onColorChanged(newColor);
          }
        },
        style: theme.textTheme.bodyMedium,
        dropdownColor: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        underline: const SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
        items: PinStyle.values.map((style) {
          return DropdownMenuItem<PinStyle>(
            value: style,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [ 
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getColorForPinStyle(style),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    _formatPinStyleName(style.toString()),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _formatPinStyleName(String style) {
    return style
        .split('.')
        .last
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (Match m) => ' ${m.group(0)}',
        )
        .trim();
  }

  static Color _getColorForPinStyle(PinStyle style) {
    switch (style) {
      case PinStyle.Rice:
        return Colors.green;
      case PinStyle.Corn:
        return Colors.yellow;
      case PinStyle.HVC:
        return Colors.purple;
      case PinStyle.Livestock:
        return Colors.deepOrange;
      case PinStyle.Fishery:
        return Colors.blue;
      case PinStyle.Organic:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  static Widget _buildDeleteButton(
      BuildContext context, Function() onDelete, ThemeData theme) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: ButtonColors.danger,
          side: BorderSide(color: ButtonColors.danger),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () =>
            _showDeleteConfirmationDialog(context, onDelete, theme),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 20, color: ButtonColors.danger),
            SizedBox(width: 8),
            Text('Delete Farm'),
          ],
        ),
      ),
    );
  }

  static void _showDeleteConfirmationDialog(
    BuildContext context,
    Function() onDelete,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Deletion',
          style: theme.textTheme.titleMedium,
        ),
        content: Text(
          'This will permanently delete the farm. Are you sure?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
