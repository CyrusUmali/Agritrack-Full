import 'package:flareline/core/models/assocs_model.dart';
import 'package:flareline/pages/assoc/assoc_profile/assoc_kpi.dart';
import 'package:flareline/pages/assoc/assoc_profile/assoc_overview.dart';
import 'package:flareline/pages/assoc/assoc_profile/sector_header.dart';
import 'package:flareline/pages/sectors/sector_service.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:provider/provider.dart';

class AssocProfile extends LayoutWidget {
  final Association association;

  const AssocProfile({super.key, required this.association});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Association Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return _SectorProfileContent(association: association, isMobile: false);
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return _SectorProfileContent(association: association, isMobile: true);
  }
}

class _SectorProfileContent extends StatefulWidget {
  final Association association;
  final bool isMobile;

  const _SectorProfileContent({
    required this.association,
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
  }

  Widget _buildContent() {
    // Use updated sector data if available, otherwise use initial data
    final currentSector = _updatedSector ?? widget.association;

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
                  // ElevatedButton(
                  //   onPressed: _loadSectorData,
                  //   child: const Text('Retry'),
                  // ),
                ],
              ),
            ),
          AssociationHeader(
              association: widget.association, isMobile: widget.isMobile),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssocKpiCards(
                    association: widget.association, isMobile: widget.isMobile),
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
                              child: AssociationOverviewPanel(
                                association: widget.association,
                                isMobile: widget.isMobile,
                              ),
                            ),
                            if (!widget.isMobile) const SizedBox(width: 16),
                            // Chart (30%)
                            // Flexible(
                            //   flex: 3,
                            //   child: _buildChartCard(context),
                            // ),
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

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
