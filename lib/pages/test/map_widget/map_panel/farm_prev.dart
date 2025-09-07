import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flutter/material.dart';
import 'package:flareline/services/lanugage_extension.dart';

class InfoCard extends StatelessWidget {
  final PolygonData polygon;
  final VoidCallback onTap;

  const InfoCard({
    Key? key,
    required this.polygon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Adjust this value as needed
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  // Color Indicator
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: polygon.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      polygon.name ?? 'Unnamed Area',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),

              // Description (if available)
              if (polygon.description != null &&
                  polygon.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  polygon.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Metadata Section
              const SizedBox(height: 12),
              _buildMetadataChip(
                icon: Icons.landscape,
                label: 'Area',
                value: polygon.area != null ? '${polygon.area} Ha' : 'N/A',
                theme: theme,
              ),

              if (polygon.parentBarangay != null) ...[
                const SizedBox(height: 8),
                _buildMetadataChip(
                  icon: Icons.location_city,
                  label: 'Barangay',
                  value: polygon.parentBarangay!,
                  theme: theme,
                ),
              ],

              // Action Hint
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  context.translate('Tap to view details'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
