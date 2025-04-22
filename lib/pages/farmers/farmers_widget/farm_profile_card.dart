import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final hasMultipleFarms = farms.length > 1;

    return CommonCard(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
            if (hasMultipleFarms) ...[
              _FarmSelector(
                farms: farms,
                selectedIndex: selectedFarmIndex,
                onSelected: (index) {
                  if (onFarmSelected != null) {
                    onFarmSelected!(
                        index); // This triggers the parent's setState
                  }
                },
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

class _FarmSelector extends StatelessWidget {
  final List<dynamic> farms;
  final int selectedIndex;
  final Function(int)? onSelected;

  const _FarmSelector({
    required this.farms,
    required this.selectedIndex,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Farm:',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(farms.length, (index) {
              final farm = farms[index];
              final isSelected = index == selectedIndex;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        onSelected?.call(index); // This triggers the callback
                        HapticFeedback
                            .lightImpact(); // Optional: Add haptic feedback
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        child: Column(
                          children: [
                            Text(
                              'Farm ${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : null,
                                  ),
                            ),
                            if (farm['farmName'] != null)
                              Text(
                                farm['farmName'].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : null,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
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
