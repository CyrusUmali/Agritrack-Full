// ignore_for_file: file_names

import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/pages/sectors/sector_service.dart';

class TopChannelWidget extends TableWidget {
  @override
  bool get showPaging => false;

  @override
  String title(BuildContext context) {
    return 'Top Sectors (by Land Area)';
  }

  @override
  BaseTableProvider viewModelBuilder(BuildContext context) {
    return TopChannelViewModel(context);
  }
}

class TopChannelViewModel extends BaseTableProvider {
  TopChannelViewModel(super.context);

  @override
  loadData(BuildContext context) async {
    try {
      final sectorService = RepositoryProvider.of<SectorService>(context);
      final apiData = await sectorService.fetchSectors();

      // Transform and sort API data in descending order by land area
      final items = apiData.map((sector) {
        final landArea = double.tryParse(
                sector['stats']?['totalLandArea']?.toString() ?? '0') ??
            0;
        return {
          'sectorName': sector['name'] ?? 'Unknown Sector',
          'landArea': landArea,
          'displayLandArea': '${landArea.toStringAsFixed(1)} hectares',
          'yield':
              '${sector['stats']?['totalYieldVolume']?.toString() ?? '0'}kg',
          'farmers': sector['stats']?['totalFarmers']?.toString() ?? '0',
          'sortKey': landArea, // For sorting
        };
      }).toList();

      // Sort in descending order by land area
      items.sort((a, b) => b['sortKey'].compareTo(a['sortKey']));

      // Limit to top 6 sectors
      final topItems = items.length > 6 ? items.sublist(0, 6) : items;

      Map<String, dynamic> map = {
        "headers": ["Sector", "Land Area", "Yield", "Farmers"],
        "rows": topItems.map((item) {
          return [
            {"text": item['sectorName']},
            {"text": item['displayLandArea']},
            {"text": item['yield'], "dataType": "tag", "tagType": "success"},
            {"text": item['farmers'], "dataType": "tag", "tagType": "secondary"}
          ];
        }).toList(),
      };

      tableDataEntity = TableDataEntity.fromJson(map);
    } catch (e) {
      // Create error display table data
      final errorMap = {
        "headers": ["Error"],
        "rows": [
          [
            {
              "text": "Failed to load data",
              "widget": Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Failed to load Top Sectors: ${e.toString()}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            }
          ]
        ],
      };

      tableDataEntity = TableDataEntity.fromJson(errorMap);

      // ToastHelper.showErrorToast(
      //   'Failed to load Top Sectors',
      //   context,
      // );
    }
  }
}
