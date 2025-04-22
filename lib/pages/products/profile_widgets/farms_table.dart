import 'package:flareline/pages/farms/farm_profile.dart';
import 'package:flutter/material.dart';

class FarmsTable extends StatelessWidget {
  final List<dynamic> farms;

  const FarmsTable({super.key, required this.farms});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      constraints.maxWidth / 5; // Divide by number of columns
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
                            child: Text('Area (acres)'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Est. Yield'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: columnWidth,
                            child: Text('Status'),
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
                                  farm['name'] ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm['location'] ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm['area']?.toString() ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: columnWidth,
                                child: Text(
                                  farm['yield']?.toString() ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(farm['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  farm['status'] ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                ),
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
