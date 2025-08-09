import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/sectors/sector_service.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/circular_chart.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_header.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_kpi.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_overview.dart';
import 'package:provider/provider.dart';

class SectorProfile extends LayoutWidget {
  final Map<String, dynamic> sector;

  const SectorProfile({super.key, required this.sector});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Sector Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return _SectorProfileContent(sector: sector, isMobile: false);
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return _SectorProfileContent(sector: sector, isMobile: true);
  }
}

class _SectorProfileContent extends StatefulWidget {
  final Map<String, dynamic> sector;
  final bool isMobile;

  const _SectorProfileContent({
    required this.sector,
    required this.isMobile,
  });

  @override
  State<_SectorProfileContent> createState() => _SectorProfileContentState();
}

class _SectorProfileContentState extends State<_SectorProfileContent> {
  late SectorService _sectorService;
  Map<String, dynamic>? _updatedSector;
  List<Map<String, dynamic>>? _yieldDistribution;
  bool _isLoading = false;
  bool _isLoadingYield = false;
  String? _error;
  String? _yieldError;

  @override
  void initState() {
    super.initState();
    _sectorService = Provider.of<SectorService>(context, listen: false);
    _loadSectorData();
    _loadYieldDistribution();
  }

  Future<void> _loadYieldDistribution() async {
    if (widget.sector['id'] == null) return;

    setState(() {
      _isLoadingYield = true;
      _yieldError = null;
    });

    try {
      final distribution = await _sectorService.fetchYieldDistribution(
        sectorId: widget.sector['id'],
        // You could add year here if needed
        // year: 2023,
      );
      setState(() {
        _yieldDistribution = distribution;
        _isLoadingYield = false;
      });
    } catch (e) {
      setState(() {
        _yieldError = e.toString();
        _isLoadingYield = false;
      });
    }
  }

  Future<void> _loadSectorData() async {
    if (widget.sector['id'] == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sector = await _sectorService.fetchSectorDetails(
        sectorId: widget.sector['id'],
      );
      setState(() {
        _updatedSector = sector;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    // Use updated sector data if available, otherwise use initial data
    final currentSector = _updatedSector ?? widget.sector;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator()
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadSectorData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          SectorHeader(sector: currentSector, isMobile: widget.isMobile),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectorKpiCards(
                    sector: currentSector, isMobile: widget.isMobile),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Flex(
                          direction:
                              widget.isMobile ? Axis.vertical : Axis.horizontal,
                          children: [
                            // Overview Panel (70%)
                            Flexible(
                              flex: 7,
                              child: SectorOverviewPanel(
                                sector: currentSector,
                                isMobile: widget.isMobile,
                              ),
                            ),
                            if (!widget.isMobile) const SizedBox(width: 16),
                            // Chart (30%)
                            Flexible(
                              flex: 3,
                              child: _buildChartCard(context),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isMobile) const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentSector = _updatedSector ?? widget.sector;

    // Prepare chart data from yield distribution
    List<Map<String, dynamic>> chartData = [];
    if (_yieldDistribution != null && _yieldDistribution!.isNotEmpty) {
      final sectorData = _yieldDistribution!.firstWhere(
        (sector) => sector['sectorId'] == currentSector['id'],
        orElse: () => _yieldDistribution!.first,
      );

      chartData =
          (sectorData['products'] as List).map<Map<String, dynamic>>((product) {
        return {
          'x': product['productName'],
          'y': product['percentageOfSectorVolume'],
        };
      }).toList();
    } else {
      // Fallback data if no distribution available
      chartData = const [
        {'x': 'No data', 'y': 100},
      ];
    }

    return Card(
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.pie_chart_outline,  ),
                const SizedBox(width: 12),
                Text(
                  'Yield Distribution',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ), 
                ),
                if (_isLoadingYield) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          if (_yieldError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _yieldError!,
                style: TextStyle(color: colors.error),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: widget.isMobile ? 300 : 300,
              child: CircularhartWidget(
                title: '',
                palette: const [
                  GlobalColors.warn,
                  GlobalColors.secondary,
                  GlobalColors.primary,
                  GlobalColors.success,
                  GlobalColors.danger,
                  GlobalColors.dark,
                  // Add more colors if you have more products
                ],
                chartData: chartData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
