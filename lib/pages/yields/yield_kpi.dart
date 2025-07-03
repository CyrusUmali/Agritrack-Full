import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mdi.dart';
import 'package:flareline/pages/sectors/sector_service.dart';

class YieldKpi extends StatefulWidget {
  const YieldKpi({super.key});

  @override
  State<YieldKpi> createState() => _YieldKpiState();
}

class _YieldKpiState extends State<YieldKpi> {
  Map<String, dynamic>? _yieldStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchYieldStatistics();
  }

  Future<void> _fetchYieldStatistics() async {
    final sectorService = RepositoryProvider.of<SectorService>(context);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await sectorService.fetchYieldStatistics();
      setState(() {
        _yieldStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading data: $_error',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchYieldStatistics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ScreenTypeLayout.builder(
      desktop: (context) => _desktopLayout(context),
      mobile: (context) => _mobileLayout(context),
      tablet: (context) => _mobileLayout(context),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _isLoading
              ? _buildShimmerCard(DeviceScreenType.desktop)
              : _buildKpiCard(
                  context,
                  const Iconify(Mdi.weight, color: Colors.deepPurple),
                  '${_yieldStats?['totalYield'] ?? '0'} t',
                  'Total Yield',
                  DeviceScreenType.desktop,
                  Colors.deepPurple[50]!,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _isLoading
              ? _buildShimmerCard(DeviceScreenType.desktop)
              : _buildKpiCard(
                  context,
                  const Iconify(Mdi.sack, color: Colors.teal),
                  _yieldStats?['averageYieldPerHectare'] ?? '0 t/ha',
                  'Avg. per Hectare',
                  DeviceScreenType.desktop,
                  Colors.teal[50]!,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _isLoading
              ? _buildShimmerCard(DeviceScreenType.desktop)
              : _buildKpiCard(
                  context,
                  const Iconify(Mdi.rice, color: Colors.orange),
                  '${_yieldStats?['topCrop']?['volume'] ?? '0'} t ${_yieldStats?['topCrop']?['product'] ?? '-'}',
                  'Top Crop',
                  DeviceScreenType.desktop,
                  Colors.orange[50]!,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _isLoading
              ? _buildShimmerCard(DeviceScreenType.desktop)
              : _buildKpiCard(
                  context,
                  const Iconify(Mdi.calendar_check, color: Colors.blue),
                  '${_yieldStats?['thisMonthYield'] ?? '0'} t',
                  'This Month',
                  DeviceScreenType.desktop,
                  Colors.blue[50]!,
                ),
        ),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _isLoading
            ? _buildShimmerCard(DeviceScreenType.mobile)
            : _buildKpiCard(
                context,
                const Iconify(Mdi.weight, color: Colors.deepPurple),
                '${_yieldStats?['totalYield'] ?? '0'} t',
                'Total Yield',
                DeviceScreenType.mobile,
                Colors.deepPurple[50]!,
              ),
        _isLoading
            ? _buildShimmerCard(DeviceScreenType.mobile)
            : _buildKpiCard(
                context,
                const Iconify(Mdi.sack, color: Colors.teal),
                _yieldStats?['averageYieldPerHectare'] ?? '0 t/ha',
                'Avg. per Hectare',
                DeviceScreenType.mobile,
                Colors.teal[50]!,
              ),
        _isLoading
            ? _buildShimmerCard(DeviceScreenType.mobile)
            : _buildKpiCard(
                context,
                const Iconify(Mdi.rice, color: Colors.orange),
                '${_yieldStats?['topCrop']?['volume'] ?? '0'} t ${_yieldStats?['topCrop']?['product'] ?? '-'}',
                'Top Crop',
                DeviceScreenType.desktop,
                Colors.orange[50]!,
              ),
        _isLoading
            ? _buildShimmerCard(DeviceScreenType.mobile)
            : _buildKpiCard(
                context,
                const Iconify(Mdi.calendar_check, color: Colors.blue),
                '${_yieldStats?['thisMonthYield'] ?? '0'} t',
                'This Month',
                DeviceScreenType.mobile,
                Colors.blue[50]!,
              ),
      ],
    );
  }

  Widget _buildShimmerCard(DeviceScreenType screenType) {
    final isDesktop = screenType == DeviceScreenType.desktop;

    return CommonCard(
      height: isDesktop ? 100 : 90,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Shimmer Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            // Shimmer Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 100,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 20,
                    width: 80,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    Widget icon,
    String value,
    String title,
    DeviceScreenType screenType,
    Color iconBgColor,
  ) {
    final isDesktop = screenType == DeviceScreenType.desktop;

    return CommonCard(
      height: isDesktop ? 100 : 90,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Column
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon,
            ),
            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
