import 'package:flutter/material.dart';
import 'suitabilty_model.dart';

class SuitabilityInputs extends StatelessWidget {
  final SuitabilityModel model;
  final bool isMobile;
  final VoidCallback onChanged;

  const SuitabilityInputs({
    super.key,
    required this.model,
    required this.isMobile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isMobile)
          _buildMobileInputs(context)
        else
          _buildDesktopInputs(context),
      ],
    );
  }

  Widget _buildDesktopInputs(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSlider(
                  context, 'Nitrogen (N, kg/ha)', model.nitrogen, 0, 150,
                  (value) {
                model.nitrogen = value;
                onChanged();
              }),
              const SizedBox(height: 16),
              _buildSlider(
                  context, 'Phosphorous (P, kg/ha)', model.phosphorous, 0, 150,
                  (value) {
                model.phosphorous = value;
                onChanged();
              }),
              const SizedBox(height: 16),
              _buildSlider(
                  context, 'Potassium (K, kg/ha)', model.potassium, 0, 220,
                  (value) {
                model.potassium = value;
                onChanged();
              }),
              const SizedBox(height: 16),
              _buildSlider(
                  context, 'Temperature (°C)', model.temperature, 0, 50,
                  (value) {
                model.temperature = value;
                onChanged();
              }),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildSlider(context, 'Humidity (%)', model.humidity, 0, 100,
                  (value) {
                model.humidity = value;
                onChanged();
              }),
              const SizedBox(height: 16),
              _buildSlider(context, 'pH Level', model.ph, 3, 10, (value) {
                model.ph = value;
                onChanged();
              }),
              const SizedBox(height: 16),
              _buildSlider(context, 'Rainfall (mm)', model.rainfall, 0, 300,
                  (value) {
                model.rainfall = value;
                onChanged();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInputs(BuildContext context) {
    return Column(
      children: [
        _buildSlider(context, 'Nitrogen (N, kg/ha)', model.nitrogen, 0, 150,
            (value) {
          model.nitrogen = value;
          onChanged();
        }),
        const SizedBox(height: 16),
        _buildSlider(
            context, 'Phosphorous (P, kg/ha)', model.phosphorous, 0, 150,
            (value) {
          model.phosphorous = value;
          onChanged();
        }),
        const SizedBox(height: 16),
        _buildSlider(context, 'Potassium (K, kg/ha)', model.potassium, 0, 220,
            (value) {
          model.potassium = value;
          onChanged();
        }),
        const SizedBox(height: 16),
        _buildSlider(context, 'Temperature (°C)', model.temperature, 0, 50,
            (value) {
          model.temperature = value;
          onChanged();
        }),
        const SizedBox(height: 16),
        _buildSlider(context, 'Humidity (%)', model.humidity, 0, 100, (value) {
          model.humidity = value;
          onChanged();
        }),
        const SizedBox(height: 16),
        _buildSlider(context, 'pH Level', model.ph, 3, 10, (value) {
          model.ph = value;
          onChanged();
        }),
        const SizedBox(height: 16),
        _buildSlider(context, 'Rainfall (mm)', model.rainfall, 0, 300, (value) {
          model.rainfall = value;
          onChanged();
        }),
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    double currentValue,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    Color activeColor = Colors.blue,
    Color inactiveColor = Colors.grey,
    double trackHeight = 1.0,
    double thumbRadius = 4.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: inactiveColor,
            trackHeight: trackHeight,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: thumbRadius,
              disabledThumbRadius: thumbRadius,
              elevation: 2.0,
              pressedElevation: 6.0,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: thumbRadius * 1.8,
            ),
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.2),
            valueIndicatorColor: activeColor,
            valueIndicatorTextStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: 100,
            label: currentValue.toStringAsFixed(1),
            onChanged: (value) {
              onChanged(value);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              currentValue.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
            Text(
              max.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
