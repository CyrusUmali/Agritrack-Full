import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/sectors/sector_service.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/circular_chart.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_header.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_kpi.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_overview.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_yield_data.dart'; // Import the new component
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
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectorKpiCards(
                    sector: currentSector, isMobile: widget.isMobile),
                const SizedBox(height: 24),
                
                // Overview Panel and Chart
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
                         
                          ],
                        ),
                      ),
                      if (widget.isMobile) const SizedBox(height: 16),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Yield Data Table
                SectorYieldDataTable(sectorId: currentSector['id'].toString()),
              ],
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