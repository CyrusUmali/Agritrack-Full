import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flareline/core/models/yield_model.dart';

enum LegendPosition {
  right,     // Default - vertical on the right
  bottom,    // Horizontal at the bottom
  horizontal // Horizontal beside the chart
}

class BarangayYieldPieChart extends StatelessWidget {
  final List<Yield> yields;
  final bool showByVolume;
  final String? selectedYear;
  final LegendPosition legendPosition; // New optional parameter

  const BarangayYieldPieChart({ 
    super.key,
    required this.yields,
    this.showByVolume = true, 
    this.selectedYear,
    this.legendPosition = LegendPosition.right, // Default to current behavior
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distributionData = _calculateDistribution();

    if (distributionData.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: theme.hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: legendPosition == LegendPosition.bottom ? 600 : 500,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Yield Distribution ${showByVolume ? '(by Volume)' : '(by Records)'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedYear != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedYear!,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildChartWithLegend(distributionData, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildChartWithLegend(Map<String, ProductDistribution> distributionData, ThemeData theme) {
    final pieChart = PieChart(
      PieChartData(
        sections: _buildPieChartSections(distributionData, theme),
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        startDegreeOffset: -90,
        borderData: FlBorderData(show: false),
      ),
    );

    switch (legendPosition) {
      case LegendPosition.right:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: pieChart,
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _buildVerticalLegend(distributionData, theme),
            ),
          ],
        );

      case LegendPosition.horizontal:
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: pieChart,
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: _buildHorizontalLegend(distributionData, theme),
            ),
          ],
        );

      case LegendPosition.bottom:
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: pieChart,
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 2,
              child: _buildHorizontalLegend(distributionData, theme),
            ),
          ],
        );
    }
  }

  Map<String, ProductDistribution> _calculateDistribution() {
    final distributionMap = <String, ProductDistribution>{};
    final filteredYields = selectedYear != null
        ? yields.where((y) => y.harvestDate?.year.toString() == selectedYear).toList()
        : yields;

    for (final yield in filteredYields) {
      final productName = yield.productName ?? 'Unknown';
      
      if (!distributionMap.containsKey(productName)) {
        distributionMap[productName] = ProductDistribution(
          productName: productName,
          totalVolume: 0,
          recordCount: 0,
          productImage: yield.productImage,
        );
      }

      distributionMap[productName]!.totalVolume += yield.volume ?? 0;
      distributionMap[productName]!.recordCount += 1;
    }

    // Sort by volume or record count depending on showByVolume flag
    final sortedEntries = distributionMap.entries.toList()
      ..sort((a, b) => showByVolume
          ? b.value.totalVolume.compareTo(a.value.totalVolume)
          : b.value.recordCount.compareTo(a.value.recordCount));

    return Map.fromEntries(sortedEntries);
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, ProductDistribution> data,
    ThemeData theme,
  ) {
    final total = showByVolume
        ? data.values.fold<double>(0, (sum, item) => sum + item.totalVolume)
        : data.values.fold<int>(0, (sum, item) => sum + item.recordCount).toDouble();

    final colors = _generateColors(data.length);
    final sections = <PieChartSectionData>[];

    int colorIndex = 0;
    for (final entry in data.entries) {
      final value = showByVolume 
          ? entry.value.totalVolume 
          : entry.value.recordCount.toDouble();
      final percentage = (value / total * 100);

      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: percentage <= 5 ? null : _buildBadge(entry.value, theme),
          badgePositionPercentageOffset: 1.3,
        ),
      );
      colorIndex++;
    }

    return sections;
  }

  Widget? _buildBadge(ProductDistribution product, ThemeData theme) {
    if (product.productImage != null) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(product.productImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return null;
  }

  Widget _buildVerticalLegend(Map<String, ProductDistribution> data, ThemeData theme) {
    final colors = _generateColors(data.length);
    final total = showByVolume
        ? data.values.fold<double>(0, (sum, item) => sum + item.totalVolume)
        : data.values.fold<int>(0, (sum, item) => sum + item.recordCount).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data.entries.elementAt(index);
              final product = entry.value;
              final color = colors[index % colors.length];
              final value = showByVolume 
                  ? product.totalVolume 
                  : product.recordCount.toDouble();
              final percentage = (value / total * 100);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                showByVolume
                                    ? '${product.totalVolume.toStringAsFixed(1)} kg'
                                    : '${product.recordCount} records',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLegend(Map<String, ProductDistribution> data, ThemeData theme) {
    final colors = _generateColors(data.length);
    final total = showByVolume
        ? data.values.fold<double>(0, (sum, item) => sum + item.totalVolume)
        : data.values.fold<int>(0, (sum, item) => sum + item.recordCount).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: legendPosition == LegendPosition.bottom ? 3 : 2,
              childAspectRatio: legendPosition == LegendPosition.bottom ? 3.5 : 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data.entries.elementAt(index);
              final product = entry.value;
              final color = colors[index % colors.length];
              final value = showByVolume 
                  ? product.totalVolume 
                  : product.recordCount.toDouble();
              final percentage = (value / total * 100);

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.productName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Color> _generateColors(int count) {
    return [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green  
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF97316), // Orange
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFF84CC16), // Lime
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFFBBF24), // Amber
    ];
  }
}

class ProductDistribution {
  final String productName;
  double totalVolume;
  int recordCount;
  final String? productImage;

  ProductDistribution({
    required this.productName,
    required this.totalVolume,
    required this.recordCount,
    this.productImage,
  });
}