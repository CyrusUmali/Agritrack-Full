import 'package:flareline/core/models/yield_model.dart';
import 'package:flutter/material.dart';
import 'barangay_model.dart';

class BarangayDataProvider extends ChangeNotifier {
  int _selectedYear;
  List<BarangayModel> _data = [];
  bool _isLoading = true;
  String _selectedProduct = '';
  List<String> _availableProducts = [];
  List<Yield> _yields = [];
  List<Yield> get yields => _yields;
  bool _disposed = false;

  List<BarangayModel> get data => _data;
  bool get isLoading => _isLoading;
  String get selectedProduct => _selectedProduct;
  List<String> get availableProducts => _availableProducts;

  set selectedProduct(String value) {
    _selectedProduct = value;
    updateColorsBasedOnYield();
    notifyListeners();
  }

  BarangayDataProvider({
    List<String>? initialProducts,
    List<Yield> yields = const [],
    required int selectedYear,
    String? initialSelectedProduct, // Add this parameter
  }) : _selectedYear = selectedYear {
    if (initialProducts != null) {
      _availableProducts = initialProducts;
    }
    _yields = yields;

    // Set initial selected product if provided and valid
    if (initialSelectedProduct != null &&
        initialSelectedProduct.isNotEmpty &&
        (initialProducts?.contains(initialSelectedProduct) ?? false)) {
      _selectedProduct = initialSelectedProduct;
    }

    // Print raw yield data before processing
    // print('Raw yield data before processing:');
    // for (var yield in _yields) {
    //   print(
    //     'Barangay: ${yield.barangay}, Farm ID: ${yield.farmId}, '
    //     'Product: ${yield.productName}, Volume: ${yield.volume}, '
    //     'Hectare: ${yield.hectare} , Date: ${yield.harvestDate}    ',
    //   );
    // }

    // Start initialization and mark as loading until complete
    _isLoading = true;
    init().then((_) {
      // This ensures loading state is properly updated
      if (!_disposed) {
        notifyListeners();
      }
    });
  }

// Add to BarangayDataProvider class
  List<BarangayModel> get filteredBarangays {
    if (_selectedProduct.isEmpty) {
      return _data;
    }

    return _data.where((barangay) {
      final yield = barangay.yieldData[_selectedProduct] ?? 0;
      return yield > 0;
    }).toList();
  }

  List<BarangayModel> get sortedBarangays {
    final barangays = filteredBarangays;

    if (_selectedProduct.isEmpty) {
      return barangays;
    }

    barangays.sort((a, b) {
      final yieldA = a.yieldData[_selectedProduct] ?? 0;
      final yieldB = b.yieldData[_selectedProduct] ?? 0;
      return yieldB.compareTo(yieldA);
    });

    return barangays;
  }

  // Add a method to filter yields by year
  List<Yield> _filterYieldsByYear(List<Yield> yields, int year) {
    return yields.where((yield) {
      if (yield.harvestDate == null) return false;

      // Handle both String and DateTime cases
      DateTime harvestDate;
      if (yield.harvestDate is String) {
        harvestDate = DateTime.parse(yield.harvestDate as String);
      } else if (yield.harvestDate is DateTime) {
        harvestDate = yield.harvestDate as DateTime;
      } else {
        return false;
      }

      return harvestDate.year == year;
    }).toList();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      print(
          '🔔 notifyListeners called - isLoading: $_isLoading, data length: ${_data.length}');
      super.notifyListeners();
    }
  }

  void printBarangayColors() {
    // print('\n=== BARANGAY COLORS ASSIGNED (NON-ZERO YIELDS ONLY) ===');
    // print('Selected Product: $_selectedProduct');
    // print('Selected Year: $_selectedYear');
    // print('Available Products: $_availableProducts');
    // print('----------------------------------------');

    int nonZeroCount = 0;

    for (var barangay in _data) {
      final yield = _selectedProduct.isEmpty
          ? 0
          : barangay.yieldData[_selectedProduct] ?? 0;

      // Skip barangays with zero yield
      if (yield == 0) {
        continue;
      }

      final color = barangay.color;

      print('${barangay.name}:');
      print('  - Color: ${color.toString()}');
      print('  - HEX: #${color.value.toRadixString(16).padLeft(8, '0')}');
      print('  - Yield: $yield');
      print('  - Area: ${barangay.area} hectares');
      print('  - Top Products: ${barangay.topProducts}');
      print('  - Yield Data: ${barangay.yieldData}');
      print('');

      nonZeroCount++;
    }

    print('Total barangays with non-zero yield: $nonZeroCount');
    print('Total barangays processed: ${_data.length}');
    print('================================\n');
  }

// Also update the init method to ensure colors are set properly:
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Filter yields by selected year before processing
      final filteredYields = _filterYieldsByYear(_yields, _selectedYear);

      final barangayNames =
          await GeoJsonParser.getBarangayNamesFromAsset('assets/barangay.json');
      barangayNames.sort();

      if (_availableProducts.isEmpty) {
        print('No products provided, using fallback');
      }

      // Group yields by barangay and farm to calculate total area per farm
      final Map<String, Map<int, double>> farmAreas = {};
      final Map<String, Map<String, double>> barangayYields = {};

      for (var _yield in filteredYields) {
        final barangay = _yield.barangay ?? 'Unknown';
        final farmId = _yield.farmId ?? 0;
        final productName = _yield.productName ?? 'Unknown';
        final volume = _yield.volume ?? 0.0;
        final hectare = _yield.hectare ?? 0.0;

        // Track unique farms and their areas
        if (!farmAreas.containsKey(barangay)) {
          farmAreas[barangay] = {};
        }
        farmAreas[barangay]![farmId] = hectare;

        // Sum yields by product for each barangay
        if (!barangayYields.containsKey(barangay)) {
          barangayYields[barangay] = {};
        }
        barangayYields[barangay]!.update(
          productName,
          (value) => value + volume,
          ifAbsent: () => volume,
        );
      }

      // Create barangay models with real data
      _data = barangayNames.map((barangay) {
        // Calculate total area (sum of unique farm areas)
        final totalArea = farmAreas[barangay]
                ?.values
                .fold(0.0, (previousValue, area) => previousValue + area) ??
            0.0;

        // Get yields for this barangay
        final yields = barangayYields[barangay] ?? {};

        // Determine top 3 products by yield
        final topProducts = yields.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topProductNames = topProducts.take(3).map((e) => e.key).toList();

        return BarangayModel(
          barangay,
          area: totalArea,
          yieldData: yields,
          farmer: topProducts.length, // Using count as placeholder
          topProducts: topProductNames,
          color: getColorForIndex(
              barangayNames.indexOf(barangay), barangayNames.length),
        );
      }).toList();

      print('📊 Created ${_data.length} barangay models');
    } catch (e) {
      _data = [];
      debugPrint('Error loading barangay data: $e');
    } finally {
      _isLoading = false;

      // IMPORTANT: Update colors AFTER data is loaded and BEFORE notifying
      if (_selectedProduct.isNotEmpty) {
        print('Updating colors for initial product: $_selectedProduct');
        updateColorsBasedOnYield();
      } else {
        // Still need to notify even if no product selected
        notifyListeners();
      }

      // Only print in debug mode
      // if (kDebugMode) {
      //   printBarangayColors();
      // }
    }
  }

  void updateColorsBasedOnYield() {
    print('\n🎨 === UPDATE COLORS DEBUG ===');
    print('Selected Product: "$_selectedProduct"');
    print('Data length: ${_data.length}');

    if (_selectedProduct.isEmpty) {
      print('No product selected - using default colors');
      // Reset to default colors if no product selected
      for (var i = 0; i < _data.length; i++) {
        _data[i].color = getColorForIndex(i, _data.length);
      }
    } else {
      // Get all yield values for the selected product
      final yields = _data
          .map((barangay) => barangay.yieldData[_selectedProduct] ?? 0.0)
          .toList();

      print('Total yields collected: ${yields.length}');

      if (yields.isEmpty) {
        print('⚠️ No yields found - this should not happen');
        return;
      }

      // Separate zero and non-zero yields
      final nonZeroYields = yields.where((y) => y > 0).toList();

      print('Non-zero yields: ${nonZeroYields.length}');
      print('Zero yields: ${yields.length - nonZeroYields.length}');

      if (nonZeroYields.isEmpty) {
        print('All yields are zero - setting all to gray');
        // All values are zero - use gray for all
        for (var barangay in _data) {
          barangay.color = Colors.grey.withOpacity(0.7);
        }
      } else {
        // We have both zero and non-zero values
        final maxYield = nonZeroYields.reduce((a, b) => a > b ? a : b);
        final minYield = nonZeroYields.reduce((a, b) => a < b ? a : b);
        final range = maxYield - minYield;

        print('Max yield: $maxYield');
        print('Min yield: $minYield');
        print('Range: $range');

        // Update colors based on yield
        for (var barangay in _data) {
          final yieldValue = barangay.yieldData[_selectedProduct] ?? 0.0;

          if (yieldValue == 0) {
            // Zero values get gray
            barangay.color = Colors.grey.withOpacity(0.7);
            print('${barangay.name}: ZERO yield → gray');
          } else {
            // Calculate normalized value only for non-zero yields
            double normalized;

            if (range == 0) {
              // All non-zero values are the same
              normalized = 0.5;
              print('${barangay.name}: Range is 0, using normalized = 0.5');
            } else {
              normalized = (yieldValue - minYield) / range;
            }

            // Ensure normalized is between 0 and 1
            normalized = normalized.clamp(0.0, 1.0);

            // Create a heatmap color (red = high, orange = low)
            final color = Color.lerp(
              const Color.fromARGB(255, 245, 192, 112), // Low - orange
              Colors.red, // High - red
              normalized,
            )!
                .withOpacity(0.7);

            barangay.color = color;

            print(
                '${barangay.name}: yield=$yieldValue, normalized=$normalized, color=${color.toString()}');
          }
        }

        print('=== COLOR UPDATE COMPLETE ===\n');
      }
    }

    notifyListeners();
  }

  Color getColorForIndex(int index, int total) {
    final hue = (index * 360 / total) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }
}
