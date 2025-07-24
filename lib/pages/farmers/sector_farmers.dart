// ignore_for_file: must_be_immutable, avoid_print, use_super_parameters, non_constant_identifier_names

import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/pages/widget/network_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/farmers/add_farmer_modal.dart';
import 'package:flareline/pages/farmers/farmer_data.dart';
import 'package:flareline/pages/farmers/farmer_profile.dart';
import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/modal/barangay_filter_modal.dart';
import 'package:flareline/pages/widget/combo_box.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:toastification/toastification.dart';

import 'package:flareline/pages/test/map_widget/stored_polygons.dart';

class FarmersPerSectorWidget extends StatefulWidget {
  const FarmersPerSectorWidget({super.key});

  @override
  State<FarmersPerSectorWidget> createState() => _FarmersPerSectorWidgetState();
}

class _FarmersPerSectorWidgetState extends State<FarmersPerSectorWidget> {
  String selectedSector = '';
  String selectedBarangay = '';
  late List<String> barangayNames;
  String _barangayFilter = ''; // Add this as a class variable

  @override
  void initState() {
    super.initState();
    barangayNames = barangays.map((b) => b['name'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmerBloc, FarmerState>(
      listener: (context, state) {
        if (state is FarmersLoaded && state.message != null) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is FarmersError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      child: _channels(),
    );
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
          _buildSearchBarDesktop(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<FarmerBloc, FarmerState>(
              builder: (context, state) {
                if (state is FarmersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FarmersError) {
                  return NetworkErrorWidget(
                    error: state.message,
                    onRetry: () {
                      // Trigger your retry logic here
                      context.read<FarmerBloc>().add(LoadFarmers());
                    },
                  );
                } else if (state is FarmersLoaded) {
                  if (state.farmers.isEmpty) {
                    return _buildNoResultsWidget();
                  }
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DataTableWidget(
                          key:
                              ValueKey('farmers_table_${state.farmers.length}'),
                          farmers: state.farmers,
                        ),
                      ),
                    ],
                  );
                }
                return _buildNoResultsWidget();
              },
            ),
          ),
        ],
      ),
    );
  }

// Update the _channelMobile widget
  Widget _channelMobile(BuildContext context) {
    return Column(
      children: [
        _buildSearchBarMobile(),
        const SizedBox(height: 16),
        SizedBox(
          height: 500,
          child: BlocBuilder<FarmerBloc, FarmerState>(
            builder: (context, state) {
              if (state is FarmersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FarmersError) {
                // return Center(child: Text(state.message));

                return NetworkErrorWidget(
                  error: state.message,
                  onRetry: () {
                    // Trigger your retry logic here
                    context.read<FarmerBloc>().add(LoadFarmers());
                  },
                );
              } else if (state is FarmersLoaded) {
                if (state.farmers.isEmpty) {
                  return _buildNoResultsWidget();
                }
                return DataTableWidget(
                  key: ValueKey('farmers_table_${state.farmers.length}'),
                  farmers: state.farmers,
                );
              }
              return _buildNoResultsWidget();
            },
          ),
        ),
      ],
    );
  }

// Add this new helper widget
  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No farmers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarMobile() {
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8, // Vertical spacing between lines when wrapping
          children: [
            // Sector ComboBox
            buildComboBox(
              context: context,
              hint: 'Sector',
              options: const [
                'All',
                'Rice',
                'Livestock',
                'Fishery',
                'Corn',
                'HVC',
                'Organic'
              ],
              selectedValue: selectedSector,
              onSelected: (value) {
                setState(() => selectedSector = value);
                context.read<FarmerBloc>().add(FilterFarmers(
                      name: '',
                      sector: (value == 'All' || value.isEmpty) ? null : value,
                      barangay: selectedBarangay,
                    ));
              },
              width: 150,
            ),

            // Barangay ComboBox
            buildComboBox(
              context: context,
              hint: 'Barangay',
              options: [
                'All',
                ...barangayNames.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(_barangayFilter.toLowerCase());
                })
              ],
              selectedValue: selectedBarangay,
              onSelected: (value) {
                setState(() => selectedBarangay = value);
                context.read<FarmerBloc>().add(FilterFarmers(
                      name: '',
                      barangay: value == 'All' ? null : value,
                      sector: selectedSector,
                    ));
              },
              width: 150,
            ),

            // Search Field
            Container(
              width: 200, // Set a minimum width for the search field
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ??
                    Colors.white, // Use card color from theme
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).cardTheme.surfaceTintColor ??
                      Colors.grey[300]!, // Use border color from theme
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).cardTheme.shadowColor ??
                        Colors.transparent,
                    blurRadius: 13,
                    offset: const Offset(0, 8),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color, // Use text color from theme
                ),
                decoration: InputDecoration(
                  hintText: 'Search farmers...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .hintColor, // Use hint color from theme
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context)
                        .iconTheme
                        .color, // Use icon color from theme
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  context.read<FarmerBloc>().add(SearchFarmers(value));
                },
              ),
            ),

            // Add Farmer Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalColors.primary, // mediumaquamarine
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () {
                  AddFarmerModal.show(
                    context: context,
                    onFarmerAdded: (farmerData) {
                      context.read<FarmerBloc>().add(AddFarmer(
                            name: farmerData.name,
                            email: farmerData.email,
                            sector: farmerData.sector,
                            phone: farmerData.phone,
                            barangay: farmerData.barangay,
                            imageUrl: farmerData.imageUrl,
                          ));
                    },
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 20, color: Colors.white),
                    SizedBox(width: 4),
                    Text("Add Farmer", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarDesktop() {
    return SizedBox(
      height: 48, // Fixed height to match first example
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sector ComboBox
          buildComboBox(
            context: context,
            hint: 'Sector',
            options: const [
              'All',
              'Rice',
              'Livestock',
              'Fishery',
              'Corn',
              'HVC',
              'Organic'
            ],
            selectedValue: selectedSector,
            onSelected: (value) {
              setState(() => selectedSector = value);
              context.read<FarmerBloc>().add(FilterFarmers(
                    name: '',
                    sector: (value == 'All' || value.isEmpty)
                        ? null
                        : value, // Modified this line
                    barangay: selectedBarangay,
                  ));
            },
            width: 150,
          ),
          const SizedBox(width: 8),

          // Barangay ComboBox
          buildComboBox(
            context: context,
            hint: 'Barangay',
            options: [
              'All',
              ...barangayNames.where((String option) {
                return option
                    .toLowerCase()
                    .contains(_barangayFilter.toLowerCase());
              })
            ],
            selectedValue: selectedBarangay,
            onSelected: (value) {
              setState(() => selectedBarangay = value);
              context.read<FarmerBloc>().add(FilterFarmers(
                    name: '',

                    barangay: value == 'All'
                        ? null
                        : value, // This will trigger "All" in bloc
                    sector: selectedSector,
                  ));
            },
            width: 150,
          ),
          const SizedBox(width: 8),

          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ??
                    Colors.white, // Use card color from theme
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).cardTheme.surfaceTintColor ??
                      Colors.grey[300]!, // Use border color from theme
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).cardTheme.shadowColor ??
                        Colors.transparent,
                    blurRadius: 13,
                    offset: const Offset(0, 8),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color, // Use text color from theme
                ),
                decoration: InputDecoration(
                  hintText: 'Search farmers...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .hintColor, // Use hint color from theme
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context)
                        .iconTheme
                        .color, // Use icon color from theme
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  context.read<FarmerBloc>().add(SearchFarmers(value));
                },
              ),
            ),
          ),

          // Add Farmer Button
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            // width: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                AddFarmerModal.show(
                  context: context,
                  onFarmerAdded: (farmerData) {
                    // Handle the farmer data here
                    context.read<FarmerBloc>().add(AddFarmer(
                          name: farmerData.name,
                          email: farmerData.email,
                          sector: farmerData.sector,
                          phone: farmerData.phone,
                          barangay: farmerData.barangay,
                          imageUrl: farmerData.imageUrl,
                        ));
                  },
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text("Add Farmer", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends TableWidget<FarmersViewModel> {
  final List<Farmer> farmers;

  DataTableWidget({
    required this.farmers,
    Key? key,
  }) : super(key: key);

  @override
  FarmersViewModel viewModelBuilder(BuildContext context) {
    return FarmersViewModel(context, farmers);
  }

  @override
  Widget headerBuilder(
      BuildContext context, String headerName, FarmersViewModel viewModel) {
    if (headerName == 'Action') {
      return Text(headerName);
    }

    return InkWell(
      onTap: () {
        context.read<FarmerBloc>().add(SortFarmers(headerName));
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
          BlocBuilder<FarmerBloc, FarmerState>(
            builder: (context, state) {
              if (state is FarmersLoaded) {
                final bloc = context.read<FarmerBloc>();
                return Icon(
                  bloc.sortColumn == headerName
                      ? (bloc.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: bloc.sortColumn == headerName
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                );
              }
              return const Icon(Icons.unfold_more,
                  size: 16, color: Colors.grey);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget actionWidgetsBuilder(
    BuildContext context,
    TableDataRowsTableDataRows columnData,
    FarmersViewModel viewModel,
  ) {
    final farmer = viewModel.farmers.firstWhere(
      (p) => p.id.toString() == columnData.id,
    );

    // final farmer = farmers.firstWhere(
    //   (f) => f.id == columnData.id,
    //   orElse: () => Farmer(
    //     id: columnData.id is String ? columnData.id as String : '5',
    //     name: 'Unknown',
    //     sector: 'Unknown',
    //     barangay: 'Unknown',
    //     contact: 'Unknown',
    //     imageUrl: '',
    //     email: '',
    //     phone: '',
    //     address: '',
    //   ),
    // );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            ModalDialog.show(
              context: context,
              title: 'Delete Farmer',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () => Navigator.of(context).pop(),
              onSaveTap: () {
                context.read<FarmerBloc>().add(DeleteFarmer(farmer.id as int));
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text('Are you sure you want to delete ${farmer.name}?'),
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
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Delete',
                          onTap: () {
                            context
                                .read<FarmerBloc>()
                                .add(DeleteFarmer(farmer.id as int));
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FarmersProfile(farmerID: int.parse(farmer.id.toString())),
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
      desktop: (context) => _buildDesktopTable(),
      mobile: (context) => _buildMobileTable(context),
      tablet: (context) => _buildMobileTable(context),
    );
  }

  Widget _buildDesktopTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double tableWidth = constraints.maxWidth > 1200
            ? 1200
            : constraints.maxWidth > 800
                ? constraints.maxWidth * 0.9
                : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SizedBox(
              width: tableWidth,
              child: super.build(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 800,
        child: super.build(context),
      ),
    );
  }
}

class FarmersViewModel extends BaseTableProvider {
  final List<Farmer> farmers;

  FarmersViewModel(super.context, this.farmers);

  @override
  Future loadData(BuildContext context) async {
    const headers = ["Farmer Name", "Sector", "Barangay", "Contact", "Action"];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (var farmer in farmers) {
      List<TableDataRowsTableDataRows> row = [];

      // Farmer Name with Image
      var farmerNameCell = TableDataRowsTableDataRows()
        ..text = farmer.name
        ..dataType = CellDataType.IMAGE_TEXT.type
        ..columnName = 'Farmer Name'
        ..imageUrl = farmer.imageUrl
        ..id = farmer.id.toString();
      row.add(farmerNameCell);

      // Sector
      var sectorCell = TableDataRowsTableDataRows()
        ..text = farmer.sector ?? 'Not specified' // Handle null sector
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Sector'
        ..id = farmer.id.toString();
      ;
      row.add(sectorCell);

      // Barangay
      var barangayCell = TableDataRowsTableDataRows()
        ..text = farmer.barangay
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Barangay'
        ..id = farmer.id.toString();
      row.add(barangayCell);

      // Contact
      var contactCell = TableDataRowsTableDataRows()
        ..text = farmer.contact
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Contact'
        ..id = farmer.id.toString();
      row.add(contactCell);

      // Action
      var actionCell = TableDataRowsTableDataRows()
        ..text = ""
        ..dataType = CellDataType.ACTION.type
        ..columnName = 'Action'
        ..id = farmer.id.toString();
      row.add(actionCell);

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
