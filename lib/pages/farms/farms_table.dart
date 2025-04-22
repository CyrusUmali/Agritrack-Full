// ignore_for_file: must_be_immutable

import 'package:flareline/pages/farms/farm_profile.dart';
import 'package:flareline/pages/modal/barangay_filter_modal.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class FarmsTableWidget extends StatefulWidget {
  const FarmsTableWidget({super.key});

  @override
  State<FarmsTableWidget> createState() => FarmsTableWidgetState();
}

class FarmsTableWidgetState extends State<FarmsTableWidget> {
  Map<String, dynamic>? selectedFarm;

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
      height: 600,
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DataTableWidget(
                    onFarmSelected: (farm) {
                      setState(() {
                        selectedFarm = farm;
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
        _buildSearchBar(),
        const SizedBox(height: 16),
        SizedBox(
          height: 450,
          child: DataTableWidget(
            onFarmSelected: (farm) {
              setState(() {
                selectedFarm = farm;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout for narrow screens (mobile)
        if (constraints.maxWidth < 600) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search farms...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterButton(
                      context,
                      icon: Icons.category,
                      label: "Sector",
                      onPressed: () => _showSectorFilter(context),
                    ),
                    _buildFilterButton(
                      context,
                      icon: Icons.location_on,
                      label: "Location",
                      onPressed: () => showBarangayFilterModal(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        // Use row layout for wider screens
        else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search farms...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildFilterButton(
                  context,
                  icon: Icons.category,
                  label: "Sector",
                  onPressed: () => _showSectorFilter(context),
                ),
                _buildFilterButton(
                  context,
                  icon: Icons.location_on,
                  label: "Location",
                  onPressed: () => showBarangayFilterModal(context),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

Widget _buildFilterButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );
}

// Custom filter button widget
class FilterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const FilterButton({
    required this.icon,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

// Show sector filter popup
void _showSectorFilter(BuildContext context) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero),
          ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  showMenu(
    context: context,
    position: position,
    items: [
      'Agriculture',
      'Fishery',
      'Livestock',
      'Rice',
      'High Value Crop',
      'Organic',
      'All Sectors',
    ].map((sector) {
      return PopupMenuItem(
        value: sector,
        child: Text(sector),
      );
    }).toList(),
  ).then((value) {
    if (value != null) {
      // Handle sector filter selection
      print('Selected sector: $value');
    }
  });
}

class DataTableWidget extends TableWidget<FarmViewModel> {
  final Function(Map<String, dynamic>)? onFarmSelected;

  DataTableWidget({this.onFarmSelected, Key? key}) : super(key: key);

  @override
  FarmViewModel viewModelBuilder(BuildContext context) {
    return FarmViewModel(
      context,
      onFarmSelected,
      (id) {
        // Delete logic
      },
    );
  }

  @override
  Widget headerBuilder(
      BuildContext context, String headerName, FarmViewModel viewModel) {
    // Skip sort icons for Action column
    if (headerName == 'Action') {
      return Text(headerName);
    }

    return InkWell(
      onTap: () {
        print('Sorting by $headerName');
        viewModel.sort(headerName);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              headerName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Builder(
            builder: (context) {
              if (viewModel._sortColumn == headerName) {
                return Icon(
                  viewModel._sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                );
              }
              return const Icon(
                Icons.unfold_more,
                size: 16,
                color: Colors.grey,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget actionWidgetsBuilder(BuildContext context,
      TableDataRowsTableDataRows columnData, FarmViewModel viewModel) {
    int id = int.tryParse(columnData.id ?? '0') ?? 0;
    final farm = {
      'farmName': 'Farm $id',
      'farmOwner': 'Owner $id',
      'sector': 'Agriculture',
      'farmSize': '${id + 1} hectares',
      'barangay': 'Barangay ${id % 5 + 1}',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            ModalDialog.show(
              context: context,
              title: 'Delete Farm',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () {
                Navigator.of(context).pop();
              },
              onSaveTap: () {
                if (viewModel.onFarmDeleted != null) {
                  viewModel.onFarmDeleted!(id);
                }
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  'Are you sure you want to delete ${farm['farmName']}?',
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
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Delete',
                          onTap: () {
                            if (viewModel.onFarmDeleted != null) {
                              viewModel.onFarmDeleted!(id);
                            }
                            Navigator.of(context).pop();
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
            if (viewModel.onFarmSelected != null) {
              viewModel.onFarmSelected!(farm);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FarmProfile(farm: farm),
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
          width: 1000, // Wider than mobile screen to enable scrolling
          child: super.build(context),
        ),
      ),
    );
  }
}

class FarmViewModel extends BaseTableProvider {
  final Function(Map<String, dynamic>)? onFarmSelected;
  final Function(int)? onFarmDeleted;

  @override
  String get TAG => 'FarmViewModel';

  String? _sortColumn;
  bool _sortAscending = true;

  FarmViewModel(super.context, this.onFarmSelected, this.onFarmDeleted);

  void sort(String columnName) {
    if (_sortColumn == columnName) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = columnName;
      _sortAscending = true;
    }

    // Sort the data based on the selected column
    if (tableDataEntity?.rows != null) {
      tableDataEntity!.rows!.sort((a, b) {
        // Find the index of the column to sort
        int columnIndex = tableDataEntity!.headers!.indexOf(columnName);
        if (columnIndex == -1 ||
            columnIndex >= a.length ||
            columnIndex >= b.length) {
          return 0;
        }

        String valueA = a[columnIndex].text ?? '';
        String valueB = b[columnIndex].text ?? '';

        int compareResult;
        if (columnName == 'Farm Size') {
          // Special handling for farm size (extract numbers)
          double sizeA =
              double.tryParse(valueA.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          double sizeB =
              double.tryParse(valueB.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          compareResult = sizeA.compareTo(sizeB);
        } else {
          compareResult = valueA.compareTo(valueB);
        }

        return _sortAscending ? compareResult : -compareResult;
      });

      notifyListeners();
    }
  }

  @override
  Future loadData(BuildContext context) async {
    const headers = [
      "Farm Name",
      "Farm Owner",
      "Sector",
      "Farm Size",
      "Barangay",
      "Action"
    ];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (int i = 0; i < 50; i++) {
      List<TableDataRowsTableDataRows> row = [];
      var id = i;
      var item = {
        'id': id.toString(),
        'farmName': 'Farm $id',
        'farmOwner': 'Owner $id',
        'sector': 'Agriculture',
        'farmSize': '${id + 1} hectares',
        'barangay': 'Barangay ${id % 5 + 1}',
      };

      var farmNameCell = TableDataRowsTableDataRows()
        ..text = item['farmName']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Farm Name'
        ..id = item['id'];
      row.add(farmNameCell);

      var farmOwnerCell = TableDataRowsTableDataRows()
        ..text = item['farmOwner']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Farm Owner'
        ..id = item['id'];
      row.add(farmOwnerCell);

      var sectorCell = TableDataRowsTableDataRows()
        ..text = item['sector']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Sector'
        ..id = item['id'];
      row.add(sectorCell);

      var farmSizeCell = TableDataRowsTableDataRows()
        ..text = item['farmSize']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Farm Size'
        ..id = item['id'];
      row.add(farmSizeCell);

      var barangayCell = TableDataRowsTableDataRows()
        ..text = item['barangay']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Barangay'
        ..id = item['id'];
      row.add(barangayCell);

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
