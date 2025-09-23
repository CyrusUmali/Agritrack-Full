import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/pages/farms/farm_profile.dart';
import 'package:flareline/pages/modal/barangay_filter_modal.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flareline/pages/widget/combo_box.dart';
import 'package:flareline/pages/widget/network_error.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:toastification/toastification.dart';

class FarmsTableWidget extends StatefulWidget {
  const FarmsTableWidget({super.key});

  @override
  State<FarmsTableWidget> createState() => _FarmsTableWidgetState();
}

class _FarmsTableWidgetState extends State<FarmsTableWidget> {
  String selectedSector = '';
  String selectedStatus = '';
  String selectedBarangay = '';
  late List<String> barangayNames;
  String _barangayFilter = '';

  @override
  void initState() {
    super.initState();
    barangayNames = barangays.map((b) => b['name'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmBloc, FarmState>(
      listenWhen: (previous, current) =>
          current is FarmsLoaded || current is FarmsError,
      listener: (context, state) {
        if (state is FarmsLoaded && state.message != null) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is FarmsError) {
          ToastHelper.showErrorToast(state.message, context, maxLines: 3);
        }
      },
      child: ScreenTypeLayout.builder(
        desktop: (context) => _farmsWeb(context),
        mobile: (context) => _farmsMobile(context),
        tablet: (context) => _farmsMobile(context),
      ),
    );
  }

  Widget _farmsWeb(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Column(
        children: [
          _buildSearchBarDesktop(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<FarmBloc, FarmState>(
              builder: (context, state) {
                if (state is FarmsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FarmsError) {
                  return NetworkErrorWidget(
                    error: state.message,
                    onRetry: () {
                      context.read<FarmBloc>().add(LoadFarms());
                    },
                  );
                } else if (state is FarmsLoaded) {
                  if (state.farms.isEmpty) {
                    return _buildNoResultsWidget();
                  }
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DataTableWidget(
                          // key: ValueKey(
                          //     'farms_table_${state.farms.length}_${state.sortColumn}_${state.sortAscending}'),

                          key: ValueKey(
                              'farms_table_${state.farms.length}_${context.read<FarmBloc>().sortColumn}_${context.read<FarmBloc>().sortAscending}'),

                          state: state,
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

  Widget _farmsMobile(BuildContext context) {
    return Column(
      children: [
        _buildSearchBarMobile(context),
        const SizedBox(height: 16),
        SizedBox(
          height: 450,
          child: BlocBuilder<FarmBloc, FarmState>(
            builder: (context, state) {
              if (state is FarmsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FarmsError) {
                return NetworkErrorWidget(
                  error: state.message,
                  onRetry: () {
                    context.read<FarmBloc>().add(LoadFarms());
                  },
                );
              } else if (state is FarmsLoaded) {
                if (state.farms.isEmpty) {
                  return _buildNoResultsWidget();
                }
                return DataTableWidget(
                  // key: ValueKey(
                  //     'farms_table_${state.farms.length}_${state.sortColumn}_${state.sortAscending}'),
                  key: ValueKey(
                      'farms_table_${state.farms.length}_${context.read<FarmBloc>().sortColumn}_${context.read<FarmBloc>().sortAscending}'),

                  state: state,
                );
              }
              return _buildNoResultsWidget();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
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

  Widget _buildSearchBarMobile(BuildContext context) {
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
                context.read<FarmBloc>().add(FilterFarms(
                    name: '',
                    sector: (value == 'All' || value.isEmpty) ? null : value,
                    barangay: selectedBarangay,
                    status: selectedStatus));
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
                context.read<FarmBloc>().add(FilterFarms(
                    name: '',
                    barangay: value == 'All' ? null : value,
                    sector: selectedSector,
                    status: selectedStatus));
              },
              width: 150,
            ),

            buildComboBox(
              context: context,
              hint: 'Status',
              options: ['All', 'Active', 'Inactive'],
              selectedValue: selectedStatus,
              onSelected: (value) {
                setState(() => selectedStatus = value);
                context.read<FarmBloc>().add(FilterFarms(
                    name: '',
                    barangay: value == 'All' ? null : value,
                    sector: selectedSector,
                    status: selectedStatus));
              },
              width: 150,
            ),

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
                  hintText: 'Search yields...',
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
                  context.read<FarmBloc>().add(SearchFarms(value));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarDesktop(BuildContext context) {
    return SizedBox(
      height: 48,
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
              context.read<FarmBloc>().add(FilterFarms(
                  name: '',
                  sector: (value == 'All' || value.isEmpty) ? null : value,
                  barangay: selectedBarangay,
                  status: selectedStatus));
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
              context.read<FarmBloc>().add(FilterFarms(
                  name: '',
                  barangay: value == 'All' ? null : value,
                  sector: selectedSector,
                  status: selectedStatus));
            },
            width: 150,
          ),
          const SizedBox(width: 8),

          buildComboBox(
            context: context,
            hint: 'Status',
            options: ['All', 'Active', 'Inactive'],
            selectedValue: selectedStatus,
            onSelected: (value) {
              setState(() => selectedStatus = value);
              context.read<FarmBloc>().add(FilterFarms(
                  name: '',
                  barangay: value == 'All' ? null : value,
                  sector: selectedSector,
                  status: selectedStatus));
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
                  hintText: 'Search Farms...',
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
                  context.read<FarmBloc>().add(SearchFarms(value));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends TableWidget<FarmsViewModel> {
  final FarmsLoaded state;

  DataTableWidget({
    required this.state,
    Key? key,
  }) : super(key: key);

  @override
  FarmsViewModel viewModelBuilder(BuildContext context) {
    return FarmsViewModel(context, state);
  }

  @override
  Widget headerBuilder(
      BuildContext context, String headerName, FarmsViewModel viewModel) {
    if (headerName == 'Action') {
      return Text(headerName);
    }

    return InkWell(
      onTap: () {
        context.read<FarmBloc>().add(SortFarms(headerName));
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
          BlocBuilder<FarmBloc, FarmState>(
            builder: (context, state) {
              if (state is FarmsLoaded) {
                final bloc = context.read<FarmBloc>();
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
    FarmsViewModel viewModel,
  ) {
    final farm = viewModel.state.farms.firstWhere(
      (f) => f.id.toString() == columnData.id,
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAdmin = userProvider.user?.role == 'admin';
    final isFarmerOwner = userProvider.farmer?.id == farm.farmerId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAdmin || isFarmerOwner)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              ModalDialog.show(
                context: context,
                title: 'Delete Farm',
                showTitle: true,
                showTitleDivider: true,
                modalType: ModalType.medium,
                onCancelTap: () => Navigator.of(context).pop(),
                onSaveTap: () {
                  context.read<FarmBloc>().add(DeleteFarm(farm.id!));
                  Navigator.of(context).pop();
                },
                child: Center(
                  child: Text(
                    'Are you sure you want to delete ${farm.name}?',
                    textAlign: TextAlign.center,
                  ),
                ),
                footer: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
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
                                  .read<FarmBloc>()
                                  .add(DeleteFarm(farm.id!));
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
                builder: (context) => FarmProfile(farmId: farm.id),
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

class FarmsViewModel extends BaseTableProvider {
  final FarmsLoaded state;

  FarmsViewModel(super.context, this.state);

  @override
  Future loadData(BuildContext context) async {
    const headers = [
      "Name",
      "Owner",
      "Barangay",
      "Hectare",
      "Sector",
      "Status",
      "Action"
    ];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (final farm in state.farms) {
      List<TableDataRowsTableDataRows> row = [];

      var nameCell = TableDataRowsTableDataRows()
        ..text = farm.name
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Name'
        ..id = farm.id.toString();
      row.add(nameCell);

      var ownerCell = TableDataRowsTableDataRows()
        ..text = farm.owner
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Owner'
        ..id = farm.id.toString();
      row.add(ownerCell);

      var barangayCell = TableDataRowsTableDataRows()
        ..text = farm.barangay
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Barangay'
        ..id = farm.id.toString();
      row.add(barangayCell);

      var hectareCell = TableDataRowsTableDataRows()
        ..text = '${farm.hectare} ha'
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Hectare'
        ..id = farm.id.toString();
      row.add(hectareCell);

      var sectorCell = TableDataRowsTableDataRows()
        ..text = farm.sector
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Sector'
        ..id = farm.id.toString();
      row.add(sectorCell);

      var statusCell = TableDataRowsTableDataRows()
        ..text = farm.status
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Status'
        ..id = farm.id.toString();
      row.add(statusCell);

      var actionCell = TableDataRowsTableDataRows()
        ..text = ""
        ..dataType = CellDataType.ACTION.type
        ..columnName = 'Action'
        ..id = farm.id.toString();
      row.add(actionCell);

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
