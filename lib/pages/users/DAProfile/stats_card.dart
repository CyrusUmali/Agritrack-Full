import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMobile;

  const StatsCard({super.key, required this.user, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Activity Stats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatItem(
              icon: Icons.assignment_outlined,
              label: 'Total Reports',
              value: user['totalReports']?.toString() ?? '0',
            ),
            const SizedBox(height: 12),
            _StatItem(
              icon: Icons.check_circle_outline,
              label: 'Resolved Cases',
              value: user['resolvedCases']?.toString() ?? '0',
            ),
            const SizedBox(height: 12),
            _StatItem(
              icon: Icons.pending_actions_outlined,
              label: 'Pending Cases',
              value: user['pendingCases']?.toString() ?? '0',
            ),
            const SizedBox(height: 12),
            _StatItem(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: user['joinDate']?.toString() ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
