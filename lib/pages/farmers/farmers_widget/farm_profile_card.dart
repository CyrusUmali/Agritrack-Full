import 'package:flutter/material.dart';
import './section_header.dart';
import './detail_field.dart';
import '../../farms/farm_widgets/farm_map_card.dart';
import 'package:flareline/pages/farms/farm_profile.dart';

class FarmProfileCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;
  final int selectedFarmIndex;
  final Function(int)? onFarmSelected;

  const FarmProfileCard({
    super.key,
    required this.farmer,
    this.isMobile = false,
    this.selectedFarmIndex = 0,
    this.onFarmSelected,
  });

  @override
  Widget build(BuildContext context) {
    final farms = farmer['farms'] as List<dynamic>? ?? [];
    final currentFarm = farms.isNotEmpty ? farms[selectedFarmIndex] : null;

    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SectionHeader(
                    title: 'Farm Profile', icon: Icons.agriculture),
                if (currentFarm != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'View full farm details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmProfile(farm: currentFarm),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (farms.length > 1) ...[
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text('Farm ${index + 1}'),
                        selected: selectedFarmIndex == index,
                        onSelected: (selected) {
                          if (onFarmSelected != null) {
                            onFarmSelected!(index);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (currentFarm != null) ...[
              _FarmDetails(farm: currentFarm),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Farm Location', icon: Icons.map),
              const SizedBox(height: 16),
              FarmMapCard(
                farm: currentFarm,
                isMobile: isMobile,
              ),
              if (currentFarm['gpsCoordinates'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Coordinates: ${currentFarm['gpsCoordinates']['latitude']}, ${currentFarm['gpsCoordinates']['longitude']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ] else ...[
              const Center(child: Text('No farm information available')),
            ],
          ],
        ),
      ),
    );
  }
}

class _FarmDetails extends StatelessWidget {
  final Map<String, dynamic> farm;

  const _FarmDetails({required this.farm});

  String _getCommoditiesString() {
    try {
      if (farm['commodities'] is List) {
        final commodities =
            List<Map<String, dynamic>>.from(farm['commodities']);
        return commodities
            .map((c) => c['type']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .join(', ');
      }
      return 'Not specified';
    } catch (e) {
      return 'Not specified';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DetailField(
                  label: 'Farm Name',
                  value: farm['farmName']?.toString() ?? 'Unnamed Farm'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailField(
                  label: 'Ownership',
                  value: farm['ownershipType']?.toString() ?? 'Not specified'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailField(
                  label: 'Location',
                  value: farm['location']?.toString() ?? 'Not specified'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailField(
                  label: 'Barangay',
                  value: farm['barangay']?.toString() ?? 'Not specified'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailField(
                  label: 'City/Municipality',
                  value: farm['city']?.toString() ?? 'Not specified'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailField(
                  label: 'Area (hectares)',
                  value: farm['areaHectares']?.toString() ?? 'Not specified'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailField(
          label: 'Main Commodities',
          value: _getCommoditiesString(),
        ),
        const SizedBox(height: 12),
        if (farm['soilType'] != null) ...[
          DetailField(
            label: 'Soil Type',
            value: farm['soilType']?.toString() ?? 'Not specified',
          ),
          const SizedBox(height: 12),
        ],
        if (farm['irrigationType'] != null) ...[
          DetailField(
            label: 'Irrigation',
            value: farm['irrigationType']?.toString() ?? 'Not specified',
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
