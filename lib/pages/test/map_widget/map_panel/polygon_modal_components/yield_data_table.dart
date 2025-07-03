import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/monthly_data_table.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/yearly_data_table.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class YieldDataTable extends StatefulWidget {
  final PolygonData polygon;

  const YieldDataTable({super.key, required this.polygon});

  @override
  State<YieldDataTable> createState() => _YieldDataTableState();
}

class _YieldDataTableState extends State<YieldDataTable> {
  late String _selectedProduct;
  bool _showMonthlyData = false;
  int selectedYear = DateTime.now().year;
  List<Yield> _yields = [];

  @override
  void initState() {
    super.initState();
    _selectedProduct = _getInitialProduct(); // Move this after _loadYieldData
    _loadYieldData();
  }

  String _getInitialProduct() {
    // Get unique products from yields or fall back to polygon products
    final products = _getUniqueProducts();

    // Safe access to first element
    if (products.isNotEmpty) {
      return products.first;
    }

    // Safe access to polygon products
    if (widget.polygon.products != null &&
        widget.polygon.products!.isNotEmpty) {
      return widget.polygon.products!.first;
    }

    // Final fallback
    return 'Mixed Crops';
  }

  List<String> _getUniqueProducts() {
    if (_yields.isEmpty) return [];
    return _yields.map((y) => y.productName ?? 'Unknown').toSet().toList();
  }

  void _loadYieldData() {
    final yieldBloc = context.read<YieldBloc>();
    yieldBloc.add(GetYieldByFarmId(widget.polygon.id!));

    yieldBloc.stream.listen((state) {
      if (state is YieldsLoaded && mounted) {
        setState(() {
          _yields = state.yields;
          // Update selected product if current one doesn't exist in new yields
          final currentProducts = _getUniqueProducts();
          if (currentProducts.isNotEmpty &&
              !currentProducts.contains(_selectedProduct)) {
            _selectedProduct = _getInitialProduct();
          }
        });
      }
    });
  }

  Map<String, Map<String, double>> _getYieldData() {
    final data = <String, Map<String, double>>{};
    final products = _getUniqueProducts();

    for (final product in products) {
      final productData = <String, double>{};

      // Group by year
      final yearGroups = <int, List<Yield>>{};
      for (final yield in _yields.where((y) => y.productName == product)) {
        final year = yield.createdAt?.year ?? DateTime.now().year;
        yearGroups.putIfAbsent(year, () => []).add(yield);
      }

      // Calculate total yield per year
      for (final entry in yearGroups.entries) {
        final totalYield = entry.value
            .fold<double>(0, (sum, yield) => sum + (yield.volume ?? 0));
        productData[entry.key.toString()] = totalYield;
      }

      data[product] = productData;
    }

    return data;
  }

  Map<String, double> _getMonthlyYieldData(String product, int year) {
    final monthlyData = <String, double>{};
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Initialize all months with 0
    for (final month in monthNames) {
      monthlyData[month] = 0;
    }

    // Filter yields for selected product and year
    final relevantYields = _yields.where((yield) {
      final yieldYear = yield.createdAt?.year ?? DateTime.now().year;
      return yield.productName == product && yieldYear == year;
    });

    // Sum yields by month
    for (final yield in relevantYields) {
      final month = yield.createdAt?.month ?? 1;
      final monthName = monthNames[month - 1];
      monthlyData[monthName] =
          (monthlyData[monthName] ?? 0) + (yield.volume ?? 0);
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
              content: SizedBox(
                height: 300,
                width: 300,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
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
    final yieldData = _getYieldData();
    final products = _getUniqueProducts();
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<YieldBloc, YieldState>(
      builder: (context, state) {
        if (state is YieldsLoaded) {
          _yields = state.yields;
          // Ensure we have a valid selected product when yields are loaded
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
          child: isWeb && screenWidth > 1200
              ? _buildWideScreenLayout(theme, yieldData, products)
              : _buildMobileLayout(theme, yieldData, products),
        );
      },
    );
  }

  Widget _buildWideScreenLayout(ThemeData theme,
      Map<String, Map<String, double>> yieldData, List<String> products) {
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

  Widget _buildMobileLayout(ThemeData theme,
      Map<String, Map<String, double>> yieldData, List<String> products) {
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

  Widget _buildProductSelectionCard(ThemeData theme, List<String> products,
      {required bool isVertical}) {
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
                Icon(Icons.agriculture, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Select Product',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
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

  Widget _buildVerticalProductList(List<String> products, ThemeData theme) {
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          children: products.map((product) {
            final isSelected = _selectedProduct == product;
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
                      const CircleAvatar(
                          // radius: 20,
                          // backgroundImage: NetworkImage(
                          //   _productImages[product] ??
                          //       'https://via.placeholder.com/50',
                          // ),
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

  Widget _buildHorizontalProductList(List<String> products, ThemeData theme) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final product = products[index];
        return ChoiceChip(
          label: Text(product),
          selected: _selectedProduct == product,
          onSelected: (selected) {
            setState(() {
              _selectedProduct = product;
            });
          },
          avatar: const CircleAvatar(
              // backgroundImage: NetworkImage(
              //   _productImages[product] ?? 'https://via.placeholder.com/50',
              // ),
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
                Icon(Icons.timeline, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Time Period',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
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
                  Icon(Icons.event, color: theme.primaryColor, size: 20),
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
                    icon: const Icon(Icons.edit),
                    label: const Text('Change'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, IconData icon, bool isSelected,
      VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataDisplayCard(
      ThemeData theme, Map<String, Map<String, double>> yieldData) {
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
                Icon(Icons.analytics, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Production Data - $_selectedProduct',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _showMonthlyData
                    ? MonthlyDataTable(
                        product: _selectedProduct,
                        year: selectedYear,
                        monthlyData: _getMonthlyYieldData(
                            _selectedProduct, selectedYear),
                      )
                    : YearlyDataTable(
                        product: _selectedProduct,
                        yearlyData: yieldData[_selectedProduct] ?? {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
