import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flareline/pages/yields/yield_profile.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:toastification/toastification.dart';
import 'package:flareline/pages/widget/combo_box.dart';

class RecentRecord extends StatefulWidget {
  final List<Yield> yields; // Add this parameter

  const RecentRecord({super.key, required this.yields}); // Update constructor

  @override
  State<RecentRecord> createState() => _RecentRecordWidgetState();
}

class _RecentRecordWidgetState extends State<RecentRecord> {
  String selectedSector = '';
  String selectedBarangay = '';
  String selectedProduct = '';
  String selectedStatus = '';
  String selectedYear = DateTime.now().year.toString();

  late List<String> barangayNames;
  String _barangayFilter = '';

  @override
  void initState() {
    super.initState();
    // print(widget.yields[0].farmName);

    barangayNames = barangays.map((b) => b['name'] as String).toList();
  }

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
      height: 550,
      child: Column(
        children: [
          _buildSearchBarDesktop(),
          const SizedBox(height: 16),
          Expanded(
            child: widget.yields.isEmpty
                ? _buildNoResultsWidget()
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DataTableWidget(
                          key: ValueKey('yields_table_${widget.yields.length}'),
                          yields: widget.yields,
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
        _buildSearchBarMobile(),
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: widget.yields.isEmpty
              ? _buildNoResultsWidget()
              : DataTableWidget(
                  key: ValueKey('yields_table_${widget.yields.length}'),
                  yields: widget.yields,
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

  Widget _buildSearchBarMobile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFarmer = userProvider.isFarmer;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductsError) {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flat,
                title: Text(state.message),
                alignment: Alignment.topRight,
                autoCloseDuration: const Duration(seconds: 3),
              );
            }
          },
        ),
        // Add similar listeners for FarmerBloc and FarmBloc if needed
      ],
      child: Builder(
        builder: (context) {
          // Get all states at once
          final productState = context.watch<ProductBloc>().state;

          // Get product names if loaded
          final productOptions = productState is ProductsLoaded
              ? ['All', ...productState.products.map((p) => p.name)]
              : ['All']; // Fallback if not loaded yet

          return SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Product ComboBox
                  buildComboBox(
                    context: context,
                    hint: 'Product',
                    options: productOptions,
                    selectedValue: selectedProduct,
                    onSelected: (value) {
                      setState(() => selectedProduct = value);
                      context.read<YieldBloc>().add(FilterYields(
                            productName: value == 'All' ? null : value,
                            sector:
                                selectedSector == 'All' ? null : selectedSector,
                            barangay: selectedBarangay == 'All'
                                ? null
                                : selectedBarangay,
                            status:
                                selectedStatus == 'All' ? null : selectedStatus,
                            year: selectedYear,
                          ));
                    },
                    width: 150,
                  ),

                  // Status ComboBox
                  buildComboBox(
                    context: context,
                    hint: 'Status',
                    options: const ['All', 'Pending', 'Accepted', 'Rejected'],
                    selectedValue: selectedStatus,
                    onSelected: (value) {
                      setState(() => selectedStatus = value);
                      context.read<YieldBloc>().add(FilterYields(
                            status: value == 'All' ? null : value,
                            sector:
                                selectedSector == 'All' ? null : selectedSector,
                            barangay: selectedBarangay == 'All'
                                ? null
                                : selectedBarangay,
                            productName: selectedProduct == 'All'
                                ? null
                                : selectedProduct,
                            year: selectedYear,
                          ));
                    },
                    width: 150,
                  ),

                  Container(
                    width: 200,
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        context.read<YieldBloc>().add(SearchYields(value));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBarDesktop() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFarmer = userProvider.isFarmer;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductsError) {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flat,
                title: Text(state.message),
                alignment: Alignment.topRight,
                autoCloseDuration: const Duration(seconds: 3),
              );
            }
          },
        ),
        // Add similar listeners for FarmerBloc and FarmBloc if needed
      ],
      child: Builder(
        builder: (context) {
          // Get all states at once
          final productState = context.watch<ProductBloc>().state;
          final farmerState = context.watch<FarmerBloc>().state;
          final farmState = context.watch<FarmBloc>().state;

          // Check if all data is loaded
          final allDataLoaded = productState is ProductsLoaded &&
              farmerState is FarmersLoaded &&
              farmState is FarmsLoaded;

          // Get product names if loaded
          final productOptions = productState is ProductsLoaded
              ? ['All', ...productState.products.map((p) => p.name)]
              : ['All']; // Fallback if not loaded yet

          return SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product ComboBox
                buildComboBox(
                  context: context,
                  hint: 'Product',
                  options: productOptions,
                  selectedValue: selectedProduct,
                  onSelected: (value) {
                    setState(() => selectedProduct = value);
                    context.read<YieldBloc>().add(FilterYields(
                          productName: value == 'All' ? null : value,
                          sector:
                              selectedSector == 'All' ? null : selectedSector,
                          barangay: selectedBarangay == 'All'
                              ? null
                              : selectedBarangay,
                          status:
                              selectedStatus == 'All' ? null : selectedStatus,
                          year: selectedYear,
                        ));
                  },
                  width: 150,
                ),
                const SizedBox(width: 8),

                // Status ComboBox
                buildComboBox(
                  context: context,
                  hint: 'Status',
                  options: const ['All', 'Pending', 'Accepted', 'Rejected'],
                  selectedValue: selectedStatus,
                  onSelected: (value) {
                    setState(() => selectedStatus = value);
                    context.read<YieldBloc>().add(FilterYields(
                          status: value == 'All' ? null : value,
                          sector:
                              selectedSector == 'All' ? null : selectedSector,
                          barangay: selectedBarangay == 'All'
                              ? null
                              : selectedBarangay,
                          productName:
                              selectedProduct == 'All' ? null : selectedProduct,
                          year: selectedYear,
                        ));
                  },
                  width: 150,
                ),
                const SizedBox(width: 8),

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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        context.read<YieldBloc>().add(SearchYields(value));
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DataTableWidget extends TableWidget<YieldsViewModel> {
  final List<Yield> yields;

  DataTableWidget({
    required this.yields,
    Key? key,
  }) : super(key: key);

  @override
  YieldsViewModel viewModelBuilder(BuildContext context) {
    return YieldsViewModel(context, yields);
  }

  @override
  Widget headerBuilder(
      BuildContext context, String headerName, YieldsViewModel viewModel) {
    if (headerName == 'Action') {
      return Text(headerName);
    }

    return InkWell(
      onTap: () {
        context.read<YieldBloc>().add(SortYields(headerName));
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
          BlocBuilder<YieldBloc, YieldState>(
            builder: (context, state) {
              if (state is YieldsLoaded) {
                final bloc = context.read<YieldBloc>();
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
    YieldsViewModel viewModel,
  ) {
    final yield = viewModel.yields.firstWhere(
      (p) => p.id.toString() == columnData.id,
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFarmer = userProvider.isFarmer;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            ModalDialog.show(
              context: context,
              title: 'Delete Yield',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () => Navigator.of(context).pop(),
              onSaveTap: () {
                context.read<YieldBloc>().add(DeleteYield(yield.id));
                Navigator.of(context).pop();
              },
              child: Center(
                child:
                    Text('Are you sure you want to delete this yield record?'),
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
                                .read<YieldBloc>()
                                .add(DeleteYield(yield.id));
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

        // Farmer Name
        if (!isFarmer)
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              // context.read<YieldBloc>().add(ApproveYield(yield.id));
            },
          ),

        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YieldProfile(yieldData: yield),
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
        width: 1150,
        child: super.build(context),
      ),
    );
  }
}

class YieldsViewModel extends BaseTableProvider {
  final List<Yield> yields;

// Add this helper method to your YieldsViewModel class
  String _getYieldWithUnit(double? volume, int? sectorId) {
    if (volume == null) return 'N/A';

    // Assuming sectorId 1 is for crops measured in kg, and others might be heads, etc.
    switch (sectorId) {
      case 1: // Crop sector (kg)
        return '${volume.toStringAsFixed(volume % 1 == 0 ? 0 : 1)} kg';
      case 2: // Livestock sector (heads)
        return '${volume.toInt()} heads';
      // Add more cases for other sectors as needed
      default:
        return volume.toString();
    }
  }

  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return 'N/A';

    try {
      DateTime dateTime;
      if (dateInput is String) {
        dateTime = DateTime.parse(dateInput);
      } else if (dateInput is DateTime) {
        dateTime = dateInput;
      } else {
        return 'Invalid date';
      }
      return DateFormat('MMMM d, y').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  YieldsViewModel(super.context, this.yields);

  @override
  Future loadData(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFarmer = userProvider.isFarmer;

    final headers = [
      "Product",
      "Area",
      "Reported Yield",
      "Date Reported",
      "Status",
      "Action"
    ];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (var yieldRecord in yields) {
      List<TableDataRowsTableDataRows> row = [];

      // Product
      var productCell = TableDataRowsTableDataRows()
        ..text = yieldRecord.productName
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Product'
        ..id = yieldRecord.id.toString();
      row.add(productCell);

      // Area
      var areaCell = TableDataRowsTableDataRows()
        // ..text = yieldRecord.hectare as String?
        ..text = '${yieldRecord.hectare} ha'
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Area'
        ..id = yieldRecord.id.toString();
      row.add(areaCell);

      // Reported Yield
      var yieldCell = TableDataRowsTableDataRows()
        ..text = _getYieldWithUnit(yieldRecord.volume, yieldRecord.sectorId)
            as String?
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Reported Yield'
        ..id = yieldRecord.id.toString();
      row.add(yieldCell);

// Then in loadData:
      var dateCell = TableDataRowsTableDataRows()
        ..text = _formatDate(yieldRecord.createdAt)
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Date Reported'
        ..id = yieldRecord.id.toString();
      row.add(dateCell);
      // Status
      var statusCell = TableDataRowsTableDataRows()
        ..text = yieldRecord.status
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Status'
        ..id = yieldRecord.id.toString();
      row.add(statusCell);

      // Action
      var actionCell = TableDataRowsTableDataRows()
        ..text = ""
        ..dataType = CellDataType.ACTION.type
        ..columnName = 'Action'
        ..id = yieldRecord.id.toString();
      row.add(actionCell);

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
