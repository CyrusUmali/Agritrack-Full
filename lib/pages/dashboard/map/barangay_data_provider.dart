import 'package:flareline/core/models/yield_model.dart';
import 'package:flutter/material.dart';
import 'barangay_model.dart';

class BarangayDataProvider extends ChangeNotifier {
  List<BarangayModel> _data = [];
  bool _isLoading = true;
  String _selectedProduct = '';
  List<String> _availableProducts = [];
  List<Yield> _yields = [];

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
  }) {
    if (initialProducts != null) {
      _availableProducts = initialProducts;
    }
    _yields = yields;

    // Print raw yield data before processing
    // print('Raw yield data before processing:');
    // for (var yield in _yields) {
    //   print('Barangay: ${yield.barangay}, Farm ID: ${yield.farmId}, '
    //       'Product: ${yield.productName}, Volume: ${yield.volume}, '
    //       'Hectare: ${yield.hectare}');
    // }

    init();
  }

  Future<void> init() async {
    try {
      final barangayNames =
          await GeoJsonParser.getBarangayNamesFromAsset('assets/barangay.json');
      barangayNames.sort();

      // If no products were passed in constructor, use fallback
      if (_availableProducts.isEmpty) {
        _availableProducts = ['Rice', 'Corn', 'Cow', 'Coconut', 'Banana'];
        print('Using fallback products');
      }

      // Group yields by barangay and farm to calculate total area per farm
      final Map<String, Map<int, double>> farmAreas = {};
      final Map<String, Map<String, double>> barangayYields = {};

      for (var _yield in _yields) {
        final barangay = _yield.barangay ?? 'Unknown';
        final farmId = _yield.farmId ?? 0;
        final productName = _yield.productName ?? 'Unknown';
        final volume = _yield.volume ?? 0;
        final hectare = _yield.hectare ?? 0;

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

      // Print processed yield data
      // print('\nProcessed yield data by barangay:');
      barangayYields.forEach((barangay, products) {
        // print('Barangay: $barangay');
        products.forEach((product, volume) {
          // print('  Product: $product, Total Volume: $volume');
        });
        final totalArea =
            farmAreas[barangay]?.values.fold(0.0, (sum, area) => sum + area) ??
                0.0;
        // print('  Total Area: $totalArea hectares');
      });

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
    } catch (e) {
      _data = [];
      debugPrint('Error loading barangay data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateColorsBasedOnYield() {
    if (_selectedProduct.isEmpty) {
      // Reset to default colors if no product selected
      for (var i = 0; i < _data.length; i++) {
        _data[i].color = getColorForIndex(i, _data.length);
      }
    } else {
      // Get all yield values for the selected product
      final yields = _data
          .map((barangay) => barangay.yieldData[_selectedProduct] ?? 0)
          .toList();

      if (yields.isEmpty) return;

      final maxYield = yields.reduce((a, b) => a > b ? a : b);
      final minYield = yields.reduce((a, b) => a < b ? a : b);
      final range = maxYield - minYield;

      if (range == 0) return; // All values are the same

      // Print yield data for the selected product
      // print('\nYield data for selected product ($_selectedProduct):');
      for (var barangay in _data) {
        final yield = barangay.yieldData[_selectedProduct] ?? 0;
        // print('${barangay.name}: $yield');
      }
      // print('Min yield: $minYield, Max yield: $maxYield');

      // Update colors based on yield
      for (var barangay in _data) {
        final yield = barangay.yieldData[_selectedProduct] ?? 0;
        final normalized = (yield - minYield) / range;

        // Create a heatmap color (red = high, green = low)
        barangay.color = Color.lerp(
          Colors.green,
          Colors.red,
          normalized,
        )!
            .withOpacity(0.7);
      }
    }

    notifyListeners();
  }

  Color getColorForIndex(int index, int total) {
    final hue = (index * 360 / total) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }
}
