// ignore_for_file: unused_import, override_on_non_overriding_member, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';

class RecommendationPage extends LayoutWidget {
  const RecommendationPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return '';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const RecommendationContent();
  }

  @override
  Widget buildContent(BuildContext context) {
    return const RecommendationContent();
  }
}

class RecommendationContent extends StatefulWidget {
  const RecommendationContent({super.key});

  @override
  _RecommendationContentState createState() => _RecommendationContentState();
}

class _RecommendationContentState extends State<RecommendationContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorousController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();

  String _recommendationResult = "";
  bool _isLoading = false;

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorousController.dispose();
    _potassiumController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    super.dispose();
  }

  Future<void> _predictCrop() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _recommendationResult = "";
      });

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _recommendationResult =
            "Based on your inputs, the recommended crop is: Wheat\n\n"
            "Confidence: 87%\n"
            "Alternative options: Barley, Oats";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, isMobile),
                SizedBox(height: isMobile ? 16 : 32),

                // Input form card
                Material(
                  elevation: isMobile ? 0 : 2,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isMobile
                          ? Border.all(color: Colors.grey.shade200)
                          : null,
                    ),
                    child: Form(
                      key: _formKey,
                      child: _buildInputForm(context, isMobile),
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 16 : 24),

                // Results card
                if (_recommendationResult.isNotEmpty || _isLoading)
                  Material(
                    elevation: isMobile ? 0 : 2,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isMobile
                            ? Border.all(color: Colors.grey.shade200)
                            : null,
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommended Crop',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                ),
                                SizedBox(height: isMobile ? 8 : 16),
                                Text(
                                  _recommendationResult,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crop Recommendation',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
                fontSize: isMobile ? 24 : null,
              ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          'Enter your soil and weather conditions to get the best crop suggestions',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                fontSize: isMobile ? 14 : null,
              ),
        ),
      ],
    );
  }

  Widget _buildInputForm(BuildContext context, bool isMobile) {
    return Column(
      children: [
        // First row of inputs - becomes column on mobile
        isMobile
            ? Column(
                children: [
                  _buildTextField(
                      _nitrogenController, "Nitrogen (ratio)", "50"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _phosphorousController, "Phosphorous (ratio)", "50"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _potassiumController, "Potassium (ratio)", "50"),
                ],
              )
            : Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _nitrogenController, "Nitrogen (ratio)", "50")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          _phosphorousController, "Phosphorous (ratio)", "50")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          _potassiumController, "Potassium (ratio)", "50")),
                ],
              ),
        SizedBox(height: isMobile ? 16 : 16),

        // Second row of inputs - becomes column on mobile
        isMobile
            ? Column(
                children: [
                  _buildTextField(_phController, "pH level", "6.5"),
                  const SizedBox(height: 16),
                  _buildTextField(_rainfallController, "Rainfall (mm)", "150"),
                ],
              )
            : Row(
                children: [
                  Expanded(
                      child: _buildTextField(_phController, "pH level", "6.5")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          _rainfallController, "Rainfall (mm)", "150")),
                ],
              ),
        SizedBox(height: isMobile ? 16 : 16),

        // Third row of inputs - becomes column on mobile
        isMobile
            ? Column(
                children: [
                  _buildTextField(
                      _temperatureController, "Temperature (°C)", "25"),
                  const SizedBox(height: 16),
                  _buildTextField(_humidityController, "Humidity (%)", "60"),
                ],
              )
            : Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _temperatureController, "Temperature (°C)", "25")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          _humidityController, "Humidity (%)", "60")),
                ],
              ),

        SizedBox(height: isMobile ? 24 : 32),

        // Submit button
        SizedBox(
          width: isMobile ? double.infinity : 200,
          height: 48,
          child: ElevatedButton(
            onPressed: _predictCrop,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4), // Google blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Get Recommendation',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
            ),
          ),
        )
      ],
    );
  }
}
