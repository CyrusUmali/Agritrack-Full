import 'package:flareline/pages/recommendation/api_uri.dart';
import 'package:flareline/pages/recommendation/api_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuitabilityModel extends ChangeNotifier {
  // Model selection
  String selectedModel = 'Random Forest';
  String? selectedCrop; // Added for crop suitability check

  // Input parameters
  double nitrogen = 50.6;
  double phosphorous = 53.4;
  double potassium = 48.1;
  double temperature = 25.6;
  double humidity = 71.5;
  double ph = 6.5;
  double rainfall = 103.5;

  // Results
  bool isLoading = false;
  Map<String, dynamic>? suitabilityResult; // Changed from predictionResult
  String? modelAccuracy;

  // Available models with accuracy
  final Map<String, Map<String, double>> models = {
    'Random Forest': {'accuracy': 0.9924},
    'Decision Tree': {'accuracy': 0.9848},
    'Logistic Regression': {'accuracy': 0.9590},
    'All Models': {'accuracy': 0.0}, // Will be calculated based on ensemble
  };

  Future<void> checkSuitability() async {
    if (selectedCrop == null) {
      throw Exception('Please select a crop first');
    }

    isLoading = true;
    suitabilityResult = null;
    notifyListeners();

    final uri = Uri.parse(ApiConstants.checkSuitability);
    //  final uri = Uri.parse('http://localhost:8000/api/v1/check-suitability');

    try {
      // Prepare selected models array
      List<String> selectedModels = [];
      if (selectedModel != 'All Models') {
        selectedModels.add(selectedModel);
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "N": nitrogen,
          "P": phosphorous,
          "K": potassium,
          "temperature": temperature,
          "humidity": humidity,
          "ph": ph,
          "rainfall": rainfall,
          "crop": selectedCrop,
          "selected_models": selectedModels.isEmpty ? null : selectedModels
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        suitabilityResult = data;

        // Calculate average confidence if multiple models were used
        if (selectedModel == 'All Models' && data['model_used'] is List) {
          final modelsUsed = (data['model_used'] as List).length;
          modelAccuracy =
              'Average confidence: ${(data['confidence'] * 100).toStringAsFixed(2)}% (${modelsUsed} models)';
        } else {
          modelAccuracy =
              'Confidence: ${(data['confidence'] * 100).toStringAsFixed(2)}%';
        }
      } else {
        throw Exception('Failed to check suitability: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSuggestions(List<String> deficientParams) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        // Uri.parse('http://localhost:8000/api/v1/get-suggestions'),
        // Uri.parse('https://aicrop.onrender.com/api/v1/get-suggestions'),
        Uri.parse(ApiConstants.getSuggestions),

        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "parameters": {
            "N": nitrogen,
            "P": phosphorous,
            "K": potassium,
            "temperature": temperature,
            "humidity": humidity,
            "ph": ph,
            "rainfall": rainfall,
            "crop": selectedCrop,
          },
          "deficient_params": deficientParams
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both String and List suggestions
        dynamic suggestions = data['suggestions'];
        List<String> processedSuggestions = [];

        if (suggestions is String) {
          processedSuggestions = [suggestions];
        } else if (suggestions is List) {
          processedSuggestions = suggestions.map((e) => e.toString()).toList();
        }

        suitabilityResult = {
          ...?suitabilityResult,
          'suggestions': processedSuggestions,
          'disclaimer': data['disclaimer'] ?? '',
        };
      } else {
        throw Exception('Failed to get suggestions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getSuggestions: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
