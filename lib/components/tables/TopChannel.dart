// ignore_for_file: file_names

import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flutter/material.dart';

class TopChannelWidget extends TableWidget {
  @override
  bool get showPaging => false;

  @override
  String title(BuildContext context) {
    return 'Top Sectors';
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
    // String res = await rootBundle.loadString('assets/api/channelTable.json');

    Map<String, dynamic> map = {
      "headers": ["Sector", "Landarea", "Yield", "Value "],
      "rows": [
        [
          {"text": "RIce"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Organic"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Corn"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Fishery"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Livestock"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "High Value Crop"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ]
      ]
    };
    TableDataEntity tableDataEntity = TableDataEntity.fromJson(map);
    this.tableDataEntity = tableDataEntity;
  }
}
