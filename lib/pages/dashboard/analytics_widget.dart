import 'package:flareline/components/charts/map_chart.dart';
import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/dashboard/map_widget.dart';
import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/circular_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/dashboard/climate_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsWidget extends StatelessWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FarmerBloc>().add(LoadFarmers());

    return BlocBuilder<FarmerBloc, FarmerState>(
      builder: (context, state) {
        if (state is FarmersLoaded) {
          final sectorData = _processSectorData(state.farmers);
          return _analytics(sectorData);
        } else if (state is FarmersError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return _buildShimmerPlaceholder();
        }
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ScreenTypeLayout.builder(
      desktop: (context) => _shimmerWeb(context),
      mobile: (context) => _shimmerMobile(context),
      tablet: (context) => _shimmerMobile(context),
    );
  }

  Widget _shimmerWeb(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Row(
        children: [
          Expanded(
            flex: 40,
            child: _buildShimmerCard(DeviceScreenType.desktop),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 35,
            child: _buildShimmerCard(DeviceScreenType.desktop),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 35,
            child: _buildShimmerCard(DeviceScreenType.desktop),
          ),
        ],
      ),
    );
  }

  Widget _shimmerMobile(BuildContext context) {
    return Column(
      children: [
        _buildShimmerCard(DeviceScreenType.mobile),
        const SizedBox(height: 16),
        _buildShimmerCard(DeviceScreenType.mobile),
        const SizedBox(height: 16),
        _buildShimmerCard(DeviceScreenType.mobile),
      ],
    );
  }

  Widget _buildShimmerCard(DeviceScreenType screenType) {
    final isDesktop = screenType == DeviceScreenType.desktop;
    final height = isDesktop ? 280 : 200;

    return CommonCard(
      height: height.toDouble(),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer header
            Container(
              height: 20,
              width: 150,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 20),
            // Shimmer content
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _processSectorData(List<Farmer> farmers) {
    final sectorCounts = <String, int>{};
    final totalFarmers = farmers.length;

    // Count farmers in each sector
    for (var farmer in farmers) {
      final sector = farmer.sector;
      sectorCounts[sector] = (sectorCounts[sector] ?? 0) + 1;
    }

    // Convert counts to percentages and sort by count (descending)
    final sortedSectors = sectorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 sectors and group the rest as "Others"
    final topSectors = sortedSectors.take(5).toList();
    final otherCount =
        sortedSectors.skip(5).fold<int>(0, (sum, entry) => sum + entry.value);

    // Prepare chart data with percentages
    final chartData = <Map<String, dynamic>>[];

    // Add top sectors
    for (var entry in topSectors) {
      final percentage = (entry.value / totalFarmers * 100).round();
      chartData.add({
        'x': entry.key,
        'y': percentage,
      });
    }

    // Add "Others" if needed
    if (otherCount > 0) {
      final othersPercentage = (otherCount / totalFarmers * 100).round();
      chartData.add({
        'x': 'Others',
        'y': othersPercentage,
      });
    }

    // Ensure total is exactly 100% by adjusting the last item
    if (chartData.isNotEmpty) {
      final total =
          chartData.fold<int>(0, (sum, item) => sum + (item['y'] as int));
      if (total != 100) {
        chartData.last['y'] = (chartData.last['y'] as int) + (100 - total);
      }
    }

    return chartData;
  }

  Widget _analytics(List<Map<String, dynamic>> sectorData) {
    return ScreenTypeLayout.builder(
      desktop: (context) => _analyticsWeb(context, sectorData),
      mobile: (context) => _analyticsMobile(context, sectorData),
      tablet: (context) => _analyticsMobile(context, sectorData),
    );
  }

  Widget _analyticsWeb(
      BuildContext context, List<Map<String, dynamic>> sectorData) {
    return SizedBox(
      height: 280,
      child: Row(
        children: [
          Expanded(
            flex: 40,
            child: CommonCard(
              child: CircularhartWidget(
                title: 'Farmer Distribution ',
                palette: const [
                  GlobalColors.warn,
                  GlobalColors.secondary,
                  GlobalColors.primary,
                  GlobalColors.success,
                  GlobalColors.danger,
                  GlobalColors.dark
                ],
                chartData: sectorData,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 35,
            child: CommonCard(
              child: const MapMiniView(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 35,
            child: CommonCard(
              child: const ClimateInfoWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsMobile(
      BuildContext context, List<Map<String, dynamic>> sectorData) {
    return Column(
      children: [
        SizedBox(
          height: 350,
          child: CommonCard(
            child: CircularhartWidget(
              title: 'Farmer Distribution by Sector (%)',
              palette: const [
                GlobalColors.warn,
                GlobalColors.secondary,
                GlobalColors.primary,
                GlobalColors.success,
                GlobalColors.danger,
                GlobalColors.dark
              ],
              chartData: sectorData,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: CommonCard(
            child: const MapMiniView(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: CommonCard(
            child: const ClimateInfoWidget(),
          ),
        ),
      ],
    );
  }
}
