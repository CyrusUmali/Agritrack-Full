import 'package:flutter/material.dart';

class SectorKpiCards extends StatelessWidget {
  final Map<String, dynamic> sector;
  final bool isMobile;

  const SectorKpiCards({
    super.key,
    required this.sector,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobileGrid(context) : _buildDesktopRow(context);
  }

  Widget _buildMobileGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: _buildAllCards(context),
    );
  }

  Widget _buildDesktopRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildAllCards(context)
            .map((card) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 200,
                    height: 160,
                    child: card,
                  ),
                ))
            .toList(),
      ),
    );
  }

  List<Widget> _buildAllCards(BuildContext context) {
    return [
      _buildKpiCard(
        context,
        title: 'Total Farms',
        value: sector['totalFarms']?.toString() ?? 'N/A',
        icon: Icons.agriculture,
      ),
      _buildKpiCard(
        context,
        title: 'Total Farmers',
        value: sector['totalFarmers']?.toString() ?? 'N/A',
        icon: Icons.people,
      ),
      _buildKpiCard(
        context,
        title: 'Avg Farm Size',
        value: sector['avgFarmSize'] != null
            ? '${sector['avgFarmSize']} ha'
            : 'N/A',
        icon: Icons.landscape,
      ),
      _buildKpiCard(
        context,
        title: 'Annual Yield',
        value: sector['annualYield'] != null
            ? '${sector['annualYield']} tons'
            : 'N/A',
        icon: Icons.assessment,
      ),
      _buildKpiCard(
        context,
        title: 'Growth %',
        value: sector['growthPercent'] != null
            ? '${sector['growthPercent']}%'
            : 'N/A',
        icon: sector['growthPercent'] != null && sector['growthPercent'] > 0
            ? Icons.trending_up
            : Icons.trending_down,
        isPositive:
            sector['growthPercent'] != null && sector['growthPercent'] > 0,
      ),
    ];
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    bool isPositive = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 80,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                if (title == 'Growth %')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPositive ? 'Up' : 'Down',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
