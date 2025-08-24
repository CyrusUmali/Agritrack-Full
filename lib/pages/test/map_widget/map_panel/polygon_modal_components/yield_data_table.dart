import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/test/map_widget/map_panel/barangay_bar_chart.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/barangay_yield_line_chart.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/barangay_yield_pie_chart.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/monthly_data_table.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/yearly_data_table.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

enum DataViewType { table, barchart, linechart, piechart }

class YieldDataTable extends StatefulWidget {
  final PolygonData polygon;
  final int? farmerId;

  const YieldDataTable({super.key, required this.polygon, this.farmerId});

  @override
  State<YieldDataTable> createState() => _YieldDataTableState();
}

class _YieldDataTableState extends State<YieldDataTable> {
  late String _selectedProduct;
  bool _showMonthlyData = false;
  DataViewType _viewType = DataViewType.table;
  int selectedYear = DateTime.now().year;
  List<Yield> _yields = [];

  bool _showPieByVolume = true; // true = by volume, false = by records
  bool _showPieChartToggle = true; // Controls visibility of toggle buttons

  bool get _isOwnerOrAdmin {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final _isFarmer = userProvider.isFarmer;
    final _farmerId = userProvider.farmer?.id;
    return _isFarmer == false || widget.polygon.farmerId == _farmerId;
  }

  @override
  void initState() {
    super.initState();
    _selectedProduct = _getInitialProduct();
    _loadYieldData();
  }

  String _getInitialProduct() {
    final products = _getUniqueProducts();
    if (products.isNotEmpty) {
      return products.first;
    }
    if (widget.polygon.products != null &&
        widget.polygon.products!.isNotEmpty) {
      return widget.polygon.products!.first;
    }
    return 'Mixed Crops';
  }

// 3. Keep the _getUniqueProducts method as original (include all products)
List<String> _getUniqueProducts() {
  if (_yields.isEmpty) return [];
  return _yields.map((y) => y.productName ?? 'Unknown').toSet().toList();
}

// 4. Update the _buildDataDisplay method to pass the new data structure
Widget _buildDataDisplay(Map<String, Map<String, Map<String, double>>> yieldData) {
  final ScrollController scrollController = ScrollController();
  Widget chartWidget;
  
  if (_viewType == DataViewType.table) {
    chartWidget = _showMonthlyData
        ? MonthlyDataTable(
            product: _selectedProduct, 
            year: selectedYear,
            monthlyData: _getMonthlyYieldData(_selectedProduct, selectedYear),
          )
        : YearlyDataTable(
            product: _selectedProduct,
            yearlyData: yieldData[_selectedProduct] != null
                ? yieldData[_selectedProduct]! as Map<String, Map<String, double>>
                : <String, Map<String, double>>{});
  } else if (_viewType == DataViewType.barchart) {
    chartWidget = _showMonthlyData
        ? MonthlyBarChart(
            product: _selectedProduct,
            year: selectedYear,
            monthlyData: _getMonthlyYieldData(_selectedProduct, selectedYear),
          )
        : YearlyBarChart(
            product: _selectedProduct,
            yearlyData: yieldData[_selectedProduct] != null
                ? yieldData[_selectedProduct]! as Map<String, Map<String, double>>
                : <String, Map<String, double>>{});
  } else if (_viewType == DataViewType.linechart) {
    chartWidget = _showMonthlyData
        ? MonthlyLineChart(
            product: _selectedProduct,
            year: selectedYear,
            monthlyData: _getMonthlyYieldData(_selectedProduct, selectedYear),
          )
        : YearlyLineChart(
            product: _selectedProduct,
            yearlyData: yieldData[_selectedProduct] != null
                ? yieldData[_selectedProduct]! as Map<String, Map<String, double>>
                : <String, Map<String, double>>{});
  } else {
    chartWidget = BarangayYieldPieChart(
      yields: _yields, // Include all yields (including livestock)
      showByVolume: _showPieByVolume,
      selectedYear: _showMonthlyData ? selectedYear.toString() : null,
    );
  }

  final isChart = _viewType == DataViewType.barchart || 
                  _viewType == DataViewType.linechart || 
                  _viewType == DataViewType.piechart;
  
  if (isChart) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8.0,
      radius: const Radius.circular(4.0),
      interactive: true,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: _showMonthlyData ? 800 : 600,
          child: chartWidget,
        ),
      ),
    );
  }
  
  return chartWidget;
}



  String? _getProductImage(String productName) {
    for (final yield in _yields) {
      if (yield.productName == productName) {
        return yield.productImage;
      }
    }
    return null;
  }

  void _loadYieldData() {
    final yieldBloc = context.read<YieldBloc>();
    yieldBloc.add(GetYieldByFarmId(widget.polygon.id!));

    yieldBloc.stream.listen((state) {
      if (state is YieldsLoaded && mounted) {
        setState(() {
          _yields = state.yields;


   print('Yields loaded: ${_yields.length}'); 
          print(_yields[0]);
    
          final currentProducts = _getUniqueProducts();
          if (currentProducts.isNotEmpty &&
              !currentProducts.contains(_selectedProduct)) {
            _selectedProduct = _getInitialProduct();
          }
        });
      }
    });
  }



Map<String, Map<String, Map<String, double>>> _getYieldData() {
  final data = <String, Map<String, Map<String, double>>>{};
  final products = _getUniqueProducts();

  for (final product in products) {
    final productData = <String, Map<String, double>>{};
    final yearGroups = <int, List<Yield>>{};

    for (final yield in _yields.where((y) => y.productName == product)) {
      final year = yield.harvestDate?.year ?? DateTime.now().year;
      yearGroups.putIfAbsent(year, () => []).add(yield);
    }

    for (final entry in yearGroups.entries) {
      final totalVolume = entry.value
          .fold<double>(0, (sum, yield) => sum + (yield.volume ?? 0));
      
      // Only include area harvested for non-livestock sectors
      final totalAreaHarvested = entry.value
          .where((yield) => yield.sectorId != 4) // Exclude livestock
          .fold<double>(0, (sum, yield) => sum + (yield.areaHarvested ?? 0));
      
      productData[entry.key.toString()] = {
        'volume': totalVolume,
        'areaHarvested': totalAreaHarvested,
      };
    }

    data[product] = productData;
  }

  return data;
}






Map<String, Map<String, double>> _getMonthlyYieldData(String product, int year) {
  final monthlyData = <String, Map<String, double>>{};
  final monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Initialize all months with zero values
  for (final month in monthNames) {
    monthlyData[month] = {
      'volume': 0.0,
      'areaHarvested': 0.0,
    };
  }

  final relevantYields = _yields.where((yield) {
    final yieldYear = yield.harvestDate?.year ?? DateTime.now().year;
    return yield.productName == product && yieldYear == year;
  });

  for (final yield in relevantYields) {
    final month = yield.harvestDate?.month ?? 1;
    final monthName = monthNames[month - 1];
    
    // Always include volume
    monthlyData[monthName]!['volume'] = 
        (monthlyData[monthName]!['volume'] ?? 0) + (yield.volume ?? 0);
    
    // Only include area harvested for non-livestock sectors
    if (yield.sectorId != 4) {
      monthlyData[monthName]!['areaHarvested'] = 
          (monthlyData[monthName]!['areaHarvested'] ?? 0) + (yield.areaHarvested ?? 0);
    }
  }

  return monthlyData;
}


  Future<void> _showYearPicker(BuildContext context) async {
    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempYear = selectedYear;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Year',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardTheme.color
                  : Colors.white,
              content: SizedBox(
                height: 300,
                width: 300,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    dividerTheme: DividerThemeData(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      thickness: 1,
                      space: 0,
                    ),
                  ),
                  child: YearPicker(
                    selectedDate: DateTime(tempYear),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime dateTime) {
                      setState(() {
                        tempYear = dateTime.year;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, tempYear);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (pickedYear != null) {
      setState(() {
        selectedYear = pickedYear;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<YieldBloc, YieldState>(
      builder: (context, state) {
        // Handle loading state
        if (state is YieldsLoading) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        // Handle error state
        if (state is YieldsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                ),
                SizedBox(height: 16),
                Text(
                  'Failed to load yield data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadYieldData,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is YieldsLoaded) {
          _yields = state.yields;
          final currentProducts = _getUniqueProducts();
          if (currentProducts.isNotEmpty &&
              !currentProducts.contains(_selectedProduct)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedProduct = _getInitialProduct();
                });
              }
            });
          }
        }

        return Padding(
          padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
          child: _isOwnerOrAdmin
              ? _buildOwnerAdminView(theme, isWeb, screenWidth)
              : _buildNonOwnerView(theme),
        );
      },
    );
  }

Widget _buildWideScreenLayout(ThemeData theme,
    Map<String, Map<String, Map<String, double>>> yieldData, List<String> products) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSelectionCard(theme, products, isVertical: true),
            const SizedBox(height: 20),
            _buildControlPanel(theme),
          ],
        ),
      ),
      const SizedBox(width: 24),
      Expanded(
        child: _buildDataDisplayCard(theme, yieldData),
      ),
    ],
  );
}


Widget _buildOwnerAdminView(ThemeData theme, bool isWeb, double screenWidth) {
  final yieldData = _getYieldData(); // This now returns the updated structure

 
  final products = _getUniqueProducts();

  return isWeb && screenWidth > 1200
      ? _buildWideScreenLayout(theme, yieldData, products)
      : _buildMobileLayout(theme, yieldData, products);
}

  Widget _buildNonOwnerView(ThemeData theme) {
    final products = _getUniqueProducts();
    final displayProducts = products.isNotEmpty ? products : ['Mixed Crops'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Color(0xFF241E30).withOpacity(0.6), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Farm Products',
                  style: theme.textTheme.titleLarge?.copyWith(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (displayProducts.isEmpty)
              const Text('No products information available')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayProducts.map((product) {
                  final productImage = _getProductImage(product);
                  return Chip(
                    label: Text(product),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? GlobalColors.darkerCardColor
                            : theme.primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: theme.primaryColor),
                    avatar: CircleAvatar(
                      backgroundImage: productImage != null
                          ? NetworkImage(productImage)
                          : null,
                      child: productImage == null
                          ? const Icon(Icons.eco, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Text(
              'Yield data is only available to the farm owner or administrators.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalProductList(List<String> products, ThemeData theme) {
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          children: products.map((product) {
            final isSelected = _selectedProduct == product;
            final productImage = _getProductImage(product);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedProduct = product;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color:
                          isSelected ? theme.primaryColor : theme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: productImage != null
                            ? NetworkImage(productImage)
                            : null,
                        child: productImage == null
                            ? const Icon(Icons.eco, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? theme.primaryColor : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: theme.primaryColor),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Updated _buildDataDisplayCard with chart options
Widget _buildDataDisplayCard(
    ThemeData theme, Map<String, Map<String, Map<String, double>>> yieldData) {
    final productImage = _getProductImage(_selectedProduct);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                
                return isMobile 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (productImage != null && _viewType != DataViewType.piechart)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(productImage),
                              ) 
                            else if (_viewType != DataViewType.piechart)
                              Icon(Icons.analytics, color: theme.primaryColor, size: 24),
                            
                            if (_viewType == DataViewType.piechart)
                              Icon(Icons.pie_chart, color: theme.primaryColor, size: 24)
                            else
                              const SizedBox.shrink(),
                              
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _viewType == DataViewType.piechart 
                                    ? 'Yield Distribution - ${widget.polygon.name}'
                                    : 'Production Data - $_selectedProduct',
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.normal
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                  
                  Center(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildViewTypeToggle(theme),
        const SizedBox(width: 12),
        if (_viewType == DataViewType.piechart)
          _buildPieChartModeToggle(theme),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _showMonthlyData ? 'Monthly View' : 'Yearly View',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  ),
),
                
                
                
                
                      ],
                    )
                  : Row(
                      children: [
                        if (productImage != null && _viewType != DataViewType.piechart)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(productImage),
                          )
                        else if (_viewType != DataViewType.piechart)
                          Icon(Icons.analytics, color: theme.primaryColor, size: 24),
                        
                        if (_viewType == DataViewType.piechart)
                          Icon(Icons.pie_chart, color: theme.primaryColor, size: 24)
                        else
                          const SizedBox.shrink(),
                          
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _viewType == DataViewType.piechart 
                                ? 'Yield Distribution - ${widget.polygon.name}'
                                : 'Production Data - $_selectedProduct',
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.normal
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildViewTypeToggle(theme),
                        const SizedBox(width: 12),
                        if (_viewType == DataViewType.piechart)
                          _buildPieChartModeToggle(theme)
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _showMonthlyData ? 'Monthly View' : 'Yearly View',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildDataDisplay(yieldData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method: View type toggle with all chart options
  Widget _buildViewTypeToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        color: theme.brightness == Brightness.dark
            ? theme.cardColor
            : Colors.grey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton(
            icon: Icons.table_chart,
            isSelected: _viewType == DataViewType.table,
            onTap: () => setState(() => _viewType = DataViewType.table),
            theme: theme,
            tooltip: 'Table View',
          ),
          Container(
            width: 1,
            height: 32,
            color: theme.dividerColor,
          ),
          _buildViewToggleButton(
            icon: Icons.bar_chart,
            isSelected: _viewType == DataViewType.barchart,
            onTap: () => setState(() => _viewType = DataViewType.barchart),
            theme: theme,
            tooltip: 'Bar Chart View',
          ),
          Container(
            width: 1,
            height: 32,
            color: theme.dividerColor,
          ),
          _buildViewToggleButton(
            icon: Icons.stacked_line_chart,
            isSelected: _viewType == DataViewType.linechart,
            onTap: () => setState(() => _viewType = DataViewType.linechart),
            theme: theme,
            tooltip: 'Line Chart View',
          ),
          Container(
            width: 1,
            height: 32,
            color: theme.dividerColor,
          ),
          _buildViewToggleButton(
            icon: Icons.pie_chart,
            isSelected: _viewType == DataViewType.piechart,
            onTap: () => setState(() => _viewType = DataViewType.piechart),
            theme: theme,
            tooltip: 'Pie Chart View',
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected
                ? theme.primaryColor
                : theme.iconTheme.color?.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // New method: Pie chart mode toggle (Volume vs Records)
  Widget _buildPieChartModeToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        color: theme.brightness == Brightness.dark
            ? theme.cardColor
            : Colors.grey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPieToggleButton(
            label: 'Volume',
            icon: Icons.scale,
            isSelected: _showPieByVolume,
            onTap: () => setState(() => _showPieByVolume = true),
            theme: theme,
          ),
          Container(
            width: 1,
            height: 28,
            color: theme.dividerColor,
          ),
          _buildPieToggleButton(
            label: 'Records',
            icon: Icons.analytics,
            isSelected: !_showPieByVolume,
            onTap: () => setState(() => _showPieByVolume = false),
            theme: theme,
          ),
        ],
      ),
    );
  }

  // New method: Individual pie toggle button
  Widget _buildPieToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.primaryColor
                  : theme.iconTheme.color?.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : null,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }



 



  Widget _buildHorizontalProductList(List<String> products, ThemeData theme) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final product = products[index];
        final productImage = _getProductImage(product);
        return ChoiceChip(
          label: Text(product),
          selected: _selectedProduct == product,
          onSelected: (selected) {
            setState(() {
              _selectedProduct = product;
            });
          },
          avatar: CircleAvatar(
            backgroundImage:
                productImage != null ? NetworkImage(productImage) : null,
            child:
                productImage == null ? const Icon(Icons.eco, size: 16) : null,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          selectedColor: theme.primaryColor.withOpacity(0.2),
        );
      },
    );
  }

  Widget _buildControlPanel(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline,
                    size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'Time Period',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleOption(
                      'Monthly',
                      Icons.calendar_month,
                      _showMonthlyData,
                      () async {
                        await _showYearPicker(context);
                        setState(() {
                          _showMonthlyData = true;
                        });
                      },
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildToggleOption(
                      'Yearly',
                      Icons.calendar_month,
                      !_showMonthlyData,
                      () {
                        setState(() {
                          _showMonthlyData = false;
                        });
                      },
                      theme,
                    ),
                  ),
                ],
              ),
            ),
            if (_showMonthlyData) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.event,
                      color: colorScheme.onSurface.withOpacity(0.6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Selected Year: $selectedYear',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showYearPicker(context),
                    icon: const Icon(
                      Icons.edit,
                    ),
                    label: const Text(
                      'Change',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelectionCard(ThemeData theme, List<String> products,
      {required bool isVertical}) {
    final colorScheme = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture_outlined,
                    size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'Select Product',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isVertical ? null : 100,
              child: products.isEmpty
                  ? const Center(child: Text('No products available'))
                  : isVertical
                      ? _buildVerticalProductList(products, theme)
                      : _buildHorizontalProductList(products, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, IconData icon, bool isSelected,
      VoidCallback onTap, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).brightness == Brightness.dark
                  ? GlobalColors.primary
                  : theme.primaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? null
                  : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMobileLayout(ThemeData theme,
    Map<String, Map<String, Map<String, double>>> yieldData, List<String> products) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildProductSelectionCard(theme, products, isVertical: false),
      const SizedBox(height: 16),
      _buildControlPanel(theme),
      const SizedBox(height: 16),
      _buildDataDisplayCard(theme, yieldData),
    ],
  );
}

}