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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Farm Name')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Area (acres)')),
                    DataColumn(label: Text('Est. Yield')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: farms.map((farm) {
                    return DataRow(
                      cells: [
                        DataCell(Text(farm['name'] ?? 'Unknown')),
                        DataCell(Text(farm['location'] ?? 'Unknown')),
                        DataCell(Text(farm['area']?.toString() ?? 'N/A')),
                        DataCell(Text(farm['yield']?.toString() ?? 'N/A')),
                        DataCell(
                          Chip(
                            label: Text(farm['status'] ?? 'Unknown'),
                            backgroundColor: _getStatusColor(farm['status']),
                          ),
                        ),
                      ],
                      onSelectChanged: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FarmProfile(farm: farm),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
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
