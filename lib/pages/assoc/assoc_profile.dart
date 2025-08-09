import 'package:flareline/core/models/assocs_model.dart';
import 'package:flareline/pages/assoc/assoc_bloc/assocs_bloc.dart';
import 'package:flareline/pages/assoc/assoc_profile/assoc_kpi.dart';
import 'package:flareline/pages/assoc/assoc_profile/assoc_overview.dart';
import 'package:flareline/pages/assoc/assoc_profile/sector_header.dart';
import 'package:flareline/pages/sectors/sector_service.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  late Association _currentAssociation; // Local state for the association

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
     _currentAssociation = widget.association;
    _sectorService = Provider.of<SectorService>(context, listen: false);
  }



    // Method to update the local association
  void _updateAssociation(Association updatedAssociation) {
    setState(() {
      _currentAssociation = updatedAssociation;
    });
  }

Widget _buildContent() {
  return BlocListener<AssocsBloc, AssocsState>(
    listener: (context, state) {
      if (state is AssocOperationSuccess) {
        // Update the local association when the operation succeeds
        setState(() {
          _currentAssociation = state.updatedAssoc;
        });
      }
    },
    child: SingleChildScrollView(
      child: Column(
        children: [
          AssociationHeader(
            association: _currentAssociation, 
            isMobile: widget.isMobile
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssocKpiCards(
                  association: _currentAssociation, 
                  isMobile: widget.isMobile
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Flex(
                          direction: widget.isMobile ? Axis.vertical : Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 7,
                              child: AssociationOverviewPanel(
                                association: _currentAssociation, // Use the local state
                                isMobile: widget.isMobile,
                                onUpdateSuccess: () {
                                  // This will trigger when the bloc operation succeeds
                                  // The BlocListener above will handle the update
                                },
                              ),
                            ),
                            if (!widget.isMobile) const SizedBox(width: 16),
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
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
