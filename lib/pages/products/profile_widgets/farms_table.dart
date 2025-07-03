import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/pages/farms/farm_profile.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';

class FarmsTable extends StatelessWidget {
  final List<Farm> farms;

  const FarmsTable({super.key, required this.farms});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farms Growing This Product (${farms.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (farms.isEmpty)
              Text(
                'No farms data available',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  double columnWidth =
                      constraints.maxWidth / 6; // Adjusted for the new column
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Farm Name'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Location'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Area (hectares)'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Volume'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Status'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width:
                                columnWidth * 0.5, // Smaller width for action
                            child: Text('Actions'),
                          ),
                        ),
                      ],
                      rows: farms.map((farm) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm.name ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm.barangay ?? 'Unknown location',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm.hectare?.toString() ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm.volume?.toString() ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                      'active'), // Setting all as active for now
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Active',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FarmProfile(farmId: farm.id ?? 0),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color? _getStatusColor(String? status) {
    if (status == null) return null;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.withOpacity(0.2);
      case 'inactive':
        return Colors.red.withOpacity(0.2);
      default:
        return null;
    }
  }
}
