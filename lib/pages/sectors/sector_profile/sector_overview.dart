import 'package:flutter/material.dart';

class SectorOverviewPanel extends StatelessWidget {
  final Map<String, dynamic> sector;
  final bool isMobile;

  const SectorOverviewPanel({
    super.key,
    required this.sector,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Rice Sector Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.description_outlined,
              label: 'Description',
              value:
                  'The rice sector is the backbone of agricultural economy, providing staple food for over half the world\'s population. It encompasses cultivation, processing, distribution and trade of rice varieties.',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              label: 'Sector Coordinator',
              value:
                  'Dr. Nguyen Van Minh\nminh.rice@sector.org | +84 987 654 321',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.flag_outlined,
              label: 'Mission',
              value:
                  'To ensure sustainable rice production, improve farmer livelihoods, and maintain food security through innovative farming techniques and fair trade practices.',
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: colors.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isHighlighted ? colors.primaryContainer : colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted
                ? Border.all(color: colors.primary.withOpacity(0.2))
                : null,
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlighted
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage with rice sector data
class RiceSectorExample extends StatelessWidget {
  const RiceSectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rice Sector Dashboard'),
        elevation: 24,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectorOverviewPanel(
                sector: {}), // Empty map as we're using hardcoded values
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
