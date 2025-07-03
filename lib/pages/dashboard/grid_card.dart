// ignore_for_file: unnecessary_string_escapes

import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/sectors/sector_service.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

class GridCard extends StatefulWidget {
  const GridCard({super.key});

  @override
  State<GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<GridCard> {
  Map<String, dynamic>? _shiValues;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchShiValues();
  }

  Future<void> _fetchShiValues() async {
    final sectorService = RepositoryProvider.of<SectorService>(context);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final shiValues = await sectorService.fetchShiValues();
      setState(() {
        _shiValues = shiValues;
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
    if (_isLoading) {
      return _buildLoadingLayout(context);
    }

    if (_error != null) {
      return _buildErrorLayout(context, _error!);
    }

    return ScreenTypeLayout.builder(
      desktop: (context) => _contentDesktopWidget(context, _shiValues!),
      mobile: (context) => _contentMobileWidget(context, _shiValues!),
      tablet: (context) => _contentMobileWidget(context, _shiValues!),
    );
  }

  Widget _buildLoadingLayout(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: (context) => Row(
        children: [
          Expanded(child: _buildShimmerCard(context, DeviceScreenType.desktop)),
          const SizedBox(width: 16),
          Expanded(child: _buildShimmerCard(context, DeviceScreenType.desktop)),
          const SizedBox(width: 16),
          Expanded(child: _buildShimmerCard(context, DeviceScreenType.desktop)),
          const SizedBox(width: 16),
          Expanded(child: _buildShimmerCard(context, DeviceScreenType.desktop)),
        ],
      ),
      mobile: (context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
        children: [
          _buildShimmerCard(context, DeviceScreenType.mobile),
          _buildShimmerCard(context, DeviceScreenType.mobile),
          _buildShimmerCard(context, DeviceScreenType.mobile),
          _buildShimmerCard(context, DeviceScreenType.mobile),
        ],
      ),
    );
  }

  Widget _buildErrorLayout(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error loading data: $error',
              style: TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchShiValues,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context, DeviceScreenType screenType) {
    return CommonCard(
      height: screenType == DeviceScreenType.desktop ? 166 : 140,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon placeholder (circular)
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                color: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 12),
            // Title placeholder
            Container(
              height: screenType == DeviceScreenType.desktop ? 20 : 16,
              width: screenType == DeviceScreenType.desktop ? 120 : 80,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 12),
            // First row of data
            Row(
              children: [
                Container(
                  height: 14,
                  width: screenType == DeviceScreenType.desktop ? 40 : 30,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 14,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Second row of data (if present)
            Row(
              children: [
                Container(
                  height: 14,
                  width: screenType == DeviceScreenType.desktop ? 40 : 30,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 14,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentDesktopWidget(
      BuildContext context, Map<String, dynamic> shiValues) {
    return Row(
      children: [
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.landscape_outlined,
            'Land Area',
            'Size:',
            '',
            true,
            'Plots:',
            '${shiValues['totalLandArea']?.toStringAsFixed(2) ?? '0'} acres',
            '${shiValues['numberOfFarms'] ?? '0'}',
            DeviceScreenType.desktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.nature_outlined,
            'Total Products',
            'Varieties:',
            '',
            true,
            '',
            '${shiValues['productVariety'] ?? '0'}',
            '',
            DeviceScreenType.desktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.group,
            'Annual Yield',
            'Volume:',
            '',
            true,
            'Value:',
            '${shiValues['totalYield']?.toStringAsFixed(2) ?? '0'} tons',
            '\$${(shiValues['totalValue'] ?? 0).toStringAsFixed(2)}',
            DeviceScreenType.desktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _itemCardWidget(
            context,
            Icons.person_2_outlined,
            'Total Farmers',
            'Active:',
            '',
            false,
            'Inactive:',
            '${shiValues['activeFarmers'] ?? '0'}',
            '${shiValues['inactiveFarmers'] ?? '0'}',
            DeviceScreenType.desktop,
          ),
        ),
      ],
    );
  }

  Widget _contentMobileWidget(
      BuildContext context, Map<String, dynamic> shiValues) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _itemCardWidget(
              context,
              Icons.landscape_outlined,
              'Land Area',
              'Size:',
              '',
              true,
              'Plots:',
              '${shiValues['totalLandArea']?.toStringAsFixed(2) ?? '0'} acres',
              '${shiValues['numberOfFarms'] ?? '0'}',
              DeviceScreenType.mobile,
            ),
            _itemCardWidget(
              context,
              Icons.nature_outlined,
              'Total Products',
              'Varieties:',
              '',
              true,
              '',
              '${shiValues['productVariety'] ?? '0'}',
              '',
              DeviceScreenType.mobile,
            ),
            _itemCardWidget(
              context,
              Icons.view_list_outlined,
              'Annual Yield',
              'Volume:',
              '',
              true,
              'Value:',
              '${shiValues['totalYield']?.toStringAsFixed(2) ?? '0'} tons',
              '\$${(shiValues['totalValue'] ?? 0).toStringAsFixed(2)}',
              DeviceScreenType.mobile,
            ),
            _itemCardWidget(
              context,
              Icons.security_rounded,
              'Total Farmers',
              'Active:',
              '',
              false,
              'Inactive:',
              '${shiValues['activeFarmers'] ?? '0'}',
              '${shiValues['inactiveFarmers'] ?? '0'}',
              DeviceScreenType.mobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _itemCardWidget(
    BuildContext context,
    IconData icons,
    String title,
    String subTitle1,
    String percentText,
    bool isGrow,
    String subTitle2,
    String subTitle1Value,
    String subTitle2Value,
    DeviceScreenType screenType,
  ) {
    double titleSize = screenType == DeviceScreenType.desktop ? 18 : 14;
    double subtitleSize = screenType == DeviceScreenType.desktop ? 10 : 8;

    return CommonCard(
      height: screenType == DeviceScreenType.desktop ? 166 : 140,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Icon(
                  icons,
                  color: GlobalColors.sideBar,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  subTitle1,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  subTitle1Value,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (subTitle2.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    subTitle2,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subTitle2Value,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension _InsertBetween on List<Widget> {
  List<Widget> insertBetween(Widget widget) {
    if (length <= 1) return this;

    for (var i = length - 1; i > 0; i--) {
      insert(i, widget);
    }
    return this;
  }
}
