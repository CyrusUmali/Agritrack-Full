import 'package:flutter/material.dart';
import '../polygon_manager.dart';

class BarangayInfoCard {
  static Widget build({
    required PolygonData barangay,
    required ThemeData theme,
    bool elevated = true,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: elevated ? 3 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Add your onTap handler
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  // Location Icon
                  Icon(Icons.location_on_outlined,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  // Barangay Name
                  Expanded(
                    child: Text(
                      barangay.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // More Info Button
                  IconButton(
                    icon: Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () {}, // Add your handler
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildStatItem(
                    icon: Icons.landscape,
                    label: 'Area',
                    value: ' hectares',
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: Icons.home_work_outlined,
                    label: 'Farms',
                    value: '0', // Replace with actual count
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: Icons.people_outline,
                    label: 'Farmers',
                    value: '0', // Replace with actual count
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Water Source',
                    value: 'N/A', // Replace with actual data
                    theme: theme,
                  ),
                ],
              ),

              // Description (if exists)
              if (barangay.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  barangay.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],

              // Footer Button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () {}, // Add view details handler
                  child: const Text('View Farms'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
