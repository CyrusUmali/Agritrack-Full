// ignore_for_file: file_names

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
      // Fallback to sorted hardcoded data if API fails
      List<Map<String, dynamic>> predefinedItems = [
        {
          'sectorName': 'Rice',
          'landArea': 150.0,
          'displayLandArea': '150 hectares',
          'yield': '75,000kg',
          'farmers': '120'
        },
        {
          'sectorName': 'Corn',
          'landArea': 100.0,
          'displayLandArea': '100 hectares',
          'yield': '60,000kg',
          'farmers': '90'
        },
        {
          'sectorName': 'Organic',
          'landArea': 20.0,
          'displayLandArea': '20 hectares',
          'yield': '10,000kg',
          'farmers': '35'
        },
        {
          'sectorName': 'Fishery',
          'landArea': 80.0,
          'displayLandArea': '80 hectares',
          'yield': '45,000kg',
          'farmers': '60'
        },
        {
          'sectorName': 'Livestock',
          'landArea': 50.0,
          'displayLandArea': '50 hectares',
          'yield': '3,000 heads',
          'farmers': '100'
        },
        {
          'sectorName': 'High Value Crop',
          'landArea': 40.0,
          'displayLandArea': '40 hectares',
          'yield': '25,000kg',
          'farmers': '50'
        },
      ];

      // Sort hardcoded data in descending order
      predefinedItems.sort((a, b) => b['landArea'].compareTo(a['landArea']));

      Map<String, dynamic> map = {
        "headers": ["Sector", "Land Area", "Yield", "Farmers"],
        "rows": predefinedItems.map((item) {
          return [
            {"text": item['sectorName']},
            {"text": item['displayLandArea']},
            {"text": item['yield'], "dataType": "tag", "tagType": "success"},
            {"text": item['farmers'], "dataType": "tag", "tagType": "secondary"}
          ];
        }).toList(),
      };

      tableDataEntity = TableDataEntity.fromJson(map);

      // Optionally show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sector data: ${e.toString()}')),
      );
    }
  }
}
