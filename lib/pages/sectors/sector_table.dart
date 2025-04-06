// ignore_for_file: must_be_immutable

import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/sectors/sector_profile.dart'; // Import the new widget
import 'package:flareline_uikit/components/buttons/button_widget.dart'; // Import the ButtonWidget
import 'package:flareline_uikit/core/theme/flareline_colors.dart'; // Import FlarelineColors

class SectorTableWidget extends StatefulWidget {
  const SectorTableWidget({super.key});

  @override
  State<SectorTableWidget> createState() => _SectorTableWidgetState();
}

class _SectorTableWidgetState extends State<SectorTableWidget> {
  Map<String, dynamic>? selectedSector;

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
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SectorDataTableWidget(
                    onSectorSelected: (sector) {
                      setState(() {
                        selectedSector = sector;
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
        SizedBox(
          height: 380,
          child: SectorDataTableWidget(
            onSectorSelected: (sector) {
              setState(() {
                selectedSector = sector;
              });
            },
          ),
        ),
      ],
    );
  }
}

class SectorDataTableWidget extends TableWidget<SectorsViewModel> {
  final Function(Map<String, dynamic>)? onSectorSelected;

  SectorDataTableWidget({this.onSectorSelected, Key? key}) : super(key: key) {
    print("SectorDataTableWidget initialized");
  }

  @override
  SectorsViewModel viewModelBuilder(BuildContext context) {
    print("Building SectorsViewModel");

    return SectorsViewModel(
      context,
      onSectorSelected,
      (id) {
        print("Deleted Sector ID: $id");
        // Add logic to remove the sector from the list or show a confirmation dialog
      },
    );
  }

  @override
  Widget actionWidgetsBuilder(BuildContext context,
      TableDataRowsTableDataRows columnData, SectorsViewModel viewModel) {
    // Create a sector object from the data
    int id = int.tryParse(columnData.id ?? '0') ?? 0;
    final sector = {
      'Sector': 'Sector $id',
      'LandArea': '${id + 1} hectares',
      'Farmers': '12',
      'Yield': '100kg',
      'Value': '100php',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            print("Delete icon clicked for Sector $id");

            ModalDialog.show(
              context: context,
              title: 'Delete Sector',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () {
                Navigator.of(context).pop(); // Close the modal
              },
              onSaveTap: () {
                // Perform the delete operation here
                if (viewModel.onSectorDeleted != null) {
                  viewModel.onSectorDeleted!(id);
                }
                Navigator.of(context).pop(); // Close the modal
              },
              child: Center(
                child: Text(
                  'Are you sure you want to delete ${sector['Sector']}?',
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
                            if (viewModel.onSectorDeleted != null) {
                              viewModel.onSectorDeleted!(id);
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
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            print("Arrow icon clicked for Sector $id");

            if (viewModel.onSectorSelected != null) {
              viewModel.onSectorSelected!(sector);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SectorProfile(sector: sector),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: _buildDesktopTable,
      mobile: _buildMobileTable,
      tablet: _buildMobileTable,
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 1000, // Set minimum width for desktop
        maxWidth: 1200, // Set maximum width for desktop
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1200, // Fixed width for desktop
          child: super.build(context),
        ),
      ),
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width, // Full width on mobile
        ),
        child: SizedBox(
          width: 700, // Wider than mobile screen to enable scrolling
          child: super.build(context),
        ),
      ),
    );
  }
}

class SectorsViewModel extends BaseTableProvider {
  final Function(Map<String, dynamic>)? onSectorSelected;
  final Function(int)? onSectorDeleted;

  @override
  String get TAG => 'SectorsViewModel';

  SectorsViewModel(super.context, this.onSectorSelected, this.onSectorDeleted);

  @override
  Future loadData(BuildContext context) async {
    const headers = [
      "Sector Name",
      "Land Area",
      "Farmers",
      "Yield",
      "Value",
      "Action"
    ];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (int i = 0; i < 50; i++) {
      List<TableDataRowsTableDataRows> row = [];
      var id = i;
      var item = {
        'id': id.toString(),
        'sectorName': 'Sector $id',
        'landArea': '${id + 1} hectares',
        'farmers': '12',
        'yield': '100kg',
        'value': '100php',
      };

      // Create regular cells
      var sectorNameCell = TableDataRowsTableDataRows()
        ..text = item['sectorName']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Sector Name'
        ..id = item['id'];
      row.add(sectorNameCell);

      var landAreaCell = TableDataRowsTableDataRows()
        ..text = item['landArea']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Land Area'
        ..id = item['id'];
      row.add(landAreaCell);

      var farmersCell = TableDataRowsTableDataRows()
        ..text = item['farmers']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Farmers'
        ..id = item['id'];
      row.add(farmersCell);

      var yieldCell = TableDataRowsTableDataRows()
        ..text = item['yield']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Yield'
        ..id = item['id'];
      row.add(yieldCell);

      var valueCell = TableDataRowsTableDataRows()
        ..text = item['value']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Value'
        ..id = item['id'];
      row.add(valueCell);

      // Add action cell for the icon button
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
