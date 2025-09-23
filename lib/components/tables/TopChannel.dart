// ignore_for_file: fileNames

import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flareline/pages/widget/network_error.dart';
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

  @override
  Widget buildBody(BuildContext context) {
    final viewModel = viewModelBuilder(context) as TopChannelViewModel;

    if (viewModel.hasError) {
      return NetworkErrorWidget(
        error: viewModel.errorMessage ?? 'Unknown error occurred',
        onRetry: () => viewModel.retryLoading(context),
      );
    }

    return Container(); // Replace with your custom widget or logic
  }
}

class TopChannelViewModel extends BaseTableProvider {
  TopChannelViewModel(super.context);

  String? _errorMessage;
  bool _hasError = false;

  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  @override
  loadData(BuildContext context) async {
    try {
      _hasError = false;
      _errorMessage = null;
      notifyListeners(); // Notify to clear error state

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
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();

      ToastHelper.showErrorToast(
        'Failed to load Top Sectors',
        context,
      );
    }
  }

  void retryLoading(BuildContext context) {
    loadData(context);
  }
}
