// ignore_for_file: must_be_immutable, avoid_print

import 'package:flareline/pages/yields/yield_profile.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';
// Import the new widget
import 'package:flareline_uikit/components/buttons/button_widget.dart'; // Import the ButtonWidget
import 'package:flareline_uikit/core/theme/flareline_colors.dart'; // Import FlarelineColors

class YieldsWidget extends StatefulWidget {
  const YieldsWidget({super.key});

  @override
  State<YieldsWidget> createState() => YieldsWidgetState();
}

class YieldsWidgetState extends State<YieldsWidget> {
  Map<String, dynamic>? selectedYield;

  @override
  Widget build(BuildContext context) {
    return _channels();
  }

  _channels() {
    return ScreenTypeLayout.builder(
      desktop: _channelsWeb,
      mobile: _channelMobile,
      tablet: _channelMobile,
    );
  }

  Widget _channelsWeb(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Column(
        children: [
          _buildSearchBar(), // Add the search bar here
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DataTableWidget(
                    onYieldSelected: (yieldData) {
                      setState(() {
                        selectedYield = yieldData;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelMobile(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(), // Add the search bar here
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: DataTableWidget(
            onYieldSelected: (yieldData) {
              setState(() {
                selectedYield = yieldData;
              });
            },
          ),
        ),
      ],
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search yields...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends TableWidget<YieldsViewModel> {
  final Function(Map<String, dynamic>)? onYieldSelected;

  DataTableWidget({this.onYieldSelected, Key? key}) : super(key: key) {
    print("DataTableWidget initialized");
  }

  @override
  YieldsViewModel viewModelBuilder(BuildContext context) {
    print("Building YieldsViewModel");

    return YieldsViewModel(
      context,
      onYieldSelected,
      (id) {
        print("Deleted Yield ID: $id");
        // Add logic to remove the yield from the list or show a confirmation dialog
      },
    );
  }

  @override
  Widget actionWidgetsBuilder(BuildContext context,
      TableDataRowsTableDataRows columnData, YieldsViewModel viewModel) {
    // Create a yield object from the data
    int id = int.tryParse(columnData.id ?? '0') ?? 0;
    final yieldData = {
      'farmerName': 'Farmer $id',
      'sector': 'Agriculture',
      'product': 'Product $id',
      'area': '${id + 1} hectares',
      'reportedYield': '${id * 100} kg',
      'dateReported': 'March ${2024 - id}',
      'status': id % 2 == 0 ? 'Pending' : 'Approved',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            print("Delete icon clicked for Yield $id");

            ModalDialog.show(
              context: context,
              title: 'Delete Yield',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () {
                Navigator.of(context).pop(); // Close the modal
              },
              onSaveTap: () {
                // Perform the delete operation here
                if (viewModel.onYieldDeleted != null) {
                  viewModel.onYieldDeleted!(id);
                }
                Navigator.of(context).pop(); // Close the modal
              },
              child: Center(
                child: Text(
                  'Are you sure you want to delete ${yieldData['farmerName']}\'s yield?',
                  textAlign: TextAlign.center,
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Cancel',
                          textColor: FlarelineColors.darkBlackText,
                          onTap: () {
                            Navigator.of(context).pop(); // Close the modal
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Delete',
                          onTap: () {
                            // Perform the delete operation here
                            if (viewModel.onYieldDeleted != null) {
                              viewModel.onYieldDeleted!(id);
                            }
                            Navigator.of(context).pop(); // Close the modal
                          },
                          type: ButtonType.primary.type,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blue),
          onPressed: () {
            print("Visit Yield Profile icon clicked for Yield $id");

            if (viewModel.onYieldSelected != null) {
              viewModel.onYieldSelected!(yieldData);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YieldProfile(yieldData: yieldData),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () {
            print("Accept icon clicked for Yield $id");

            // Add logic to approve the yield
            if (viewModel.onYieldSelected != null) {
              viewModel.onYieldSelected!(yieldData);
            }

            // Show a confirmation dialog
            ModalDialog.show(
              context: context,
              title: 'Approve Yield',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () {
                Navigator.of(context).pop(); // Close the modal
              },
              onSaveTap: () {
                // Perform the approval operation here
                Navigator.of(context).pop(); // Close the modal
              },
              child: Center(
                child: Text(
                  'Are you sure you want to approve ${yieldData['farmerName']}\'s yield?',
                  textAlign: TextAlign.center,
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Cancel',
                          textColor: FlarelineColors.darkBlackText,
                          onTap: () {
                            Navigator.of(context).pop(); // Close the modal
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Approve',
                          onTap: () {
                            // Perform the approval operation here
                            Navigator.of(context).pop(); // Close the modal
                          },
                          type: ButtonType.primary.type,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: SizedBox(
              width: 1200,
              child: super.build(context),
            ),
          ),
        );
      },
    );
  }
}

class YieldsViewModel extends BaseTableProvider {
  final Function(Map<String, dynamic>)? onYieldSelected;
  final Function(int)? onYieldDeleted;

  @override
  String get TAG => 'YieldsViewModel';

  YieldsViewModel(super.context, this.onYieldSelected, this.onYieldDeleted);

  @override
  Future loadData(BuildContext context) async {
    const headers = [
      "Farmer Name",
      "Sector",
      "Product",
      "Area",
      "Reported Yield",
      "Date Reported",
      "Status",
      "Action"
    ];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (int i = 0; i < 50; i++) {
      List<TableDataRowsTableDataRows> row = [];
      var id = i;
      var item = {
        'id': id.toString(),
        'farmerName': 'Farmer $id',
        'sector': 'Agriculture',
        'product': 'Product $id',
        'area': '${id + 1} hectares',
        'reportedYield': '${id * 100} kg',
        'dateReported': 'March ${2024 - id}',
        'status': id % 2 == 0 ? 'Pending' : 'Approved',
      };

      // Create regular cells
      var farmerNameCell = TableDataRowsTableDataRows()
        ..text = item['farmerName']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Farmer Name'
        ..id = item['id'];
      row.add(farmerNameCell);

      var sectorCell = TableDataRowsTableDataRows()
        ..text = item['sector']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Sector'
        ..id = item['id'];
      row.add(sectorCell);

      var productCell = TableDataRowsTableDataRows()
        ..text = item['product']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Product'
        ..id = item['id'];
      row.add(productCell);

      var areaCell = TableDataRowsTableDataRows()
        ..text = item['area']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Area'
        ..id = item['id'];
      row.add(areaCell);

      var reportedYieldCell = TableDataRowsTableDataRows()
        ..text = item['reportedYield']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Reported Yield'
        ..id = item['id'];
      row.add(reportedYieldCell);

      var dateReportedCell = TableDataRowsTableDataRows()
        ..text = item['dateReported']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Date Reported'
        ..id = item['id'];
      row.add(dateReportedCell);

      var statusCell = TableDataRowsTableDataRows()
        ..text = item['status']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Status'
        ..id = item['id'];
      row.add(statusCell);

      // Add action cell for the icon buttons
      var actionCell = TableDataRowsTableDataRows()
        ..text = ""
        ..dataType = CellDataType.ACTION.type
        ..columnName = 'Action'
        ..id = item['id'];
      row.add(actionCell);

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
