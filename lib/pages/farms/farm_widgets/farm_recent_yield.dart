// ignore_for_file: file_names

import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flutter/material.dart';

class RecentYieldWidget extends TableWidget {
  @override
  bool get showPaging => false;

  @override
  String title(BuildContext context) {
    return 'Recent Yields';
  }

  @override
  BaseTableProvider viewModelBuilder(BuildContext context) {
    return RecentYieldViewModel(context);
  }
}

class RecentYieldViewModel extends BaseTableProvider {
  RecentYieldViewModel(super.context);

  @override
  Future<void> loadData(BuildContext context) async {
    Map<String, dynamic> map = {
      "headers": ["Product", "Quantity", "Unit", "Date Submitted"],
      "rows": [
        [
          {"text": "Tomatoes"},
          {"text": "120"},
          {"text": "kg"},
          {"text": "2025-04-01", "dataType": "tag", "tagType": "info"},
        ],
        [
          {"text": "Lettuce"},
          {"text": "85"},
          {"text": "kg"},
          {"text": "2025-04-02", "dataType": "tag", "tagType": "info"},
        ],
        [
          {"text": "Carrots"},
          {"text": "150"},
          {"text": "kg"},
          {"text": "2025-04-03", "dataType": "tag", "tagType": "info"},
        ],
        [
          {"text": "Onions"},
          {"text": "95"},
          {"text": "kg"},
          {"text": "2025-04-04", "dataType": "tag", "tagType": "info"},
        ],
      ]
    };

    tableDataEntity = TableDataEntity.fromJson(map);
  }
}
