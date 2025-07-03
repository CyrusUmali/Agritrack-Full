import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentYieldWidget extends TableWidget {
  final List<dynamic> yields;
  final bool isLoading;

  RecentYieldWidget({
    super.key,
    required this.yields,
    required this.isLoading,
  });

  @override
  bool get showPaging => true;

  @override
  String title(BuildContext context) {
    return 'Recent Yield Records';
  }

  @override
  BaseTableProvider viewModelBuilder(BuildContext context) {
    return RecentYieldViewModel(context, yields: yields, isLoading: isLoading);
  }
}

class RecentYieldViewModel extends BaseTableProvider {
  final List<dynamic> yields;
  final bool isLoading;

  RecentYieldViewModel(super.context,
      {required this.yields, required this.isLoading});

  @override
  Future<void> loadData(BuildContext context) async {
    if (isLoading) {
      return;
    }

    // Initialize with empty data
    Map<String, dynamic> map = {
      "headers": ["Product", "Quantity", "Date Submitted"],
      "rows": []
    };

    if (yields.isEmpty) {
      // Add a single row indicating no records
      map["rows"].add([
        {"text": "No yield records found", "colSpan": 3, "alignment": "center"}
      ]);
    } else {
      // Process data when records exist
      yields.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final dateFormat = DateFormat('yyyy-MM-dd');

      map["rows"] = yields.take(5).map((item) {
        return [
          {"text": item.productName ?? 'Unknown Product'},
          {"text": item.volume.toString()},
          {
            "text": dateFormat.format(item.createdAt),
            "dataType": "tag",
            "tagType": "info"
          },
        ];
      }).toList();
    }

    tableDataEntity = TableDataEntity.fromJson(map);
  }
}
