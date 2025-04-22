import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';

class SuitabilityResults extends StatelessWidget {
  final Map<String, dynamic> suitabilityResult;
  final Function() onGetSuggestions;
  final bool isLoadingSuggestions;

  const SuitabilityResults({
    super.key,
    required this.suitabilityResult,
    required this.onGetSuggestions,
    required this.isLoadingSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    final isSuitable = suitabilityResult['is_suitable'] as bool;
    final parametersAnalysis =
        suitabilityResult['parameters_analysis'] as Map<String, dynamic>;
    final deficientParams = parametersAnalysis.entries
        .where((e) => e.value['status'] != 'optimal')
        .toList();

    // Extract suggestions - handle both String and List<String> cases
    dynamic suggestions = suitabilityResult['suggestions'];
    String suggestionsText = '';

    // Log the raw suggestions data
    debugPrint('Raw suggestions data: $suggestions');
    debugPrint('Suggestions type: ${suggestions.runtimeType}');

    if (suggestions != null) {
      if (suggestions is List) {
        debugPrint('Suggestions is a List with ${suggestions.length} items');
        suggestionsText = suggestions.join('\n\n');
      } else {
        debugPrint('Suggestions is a single value');
        suggestionsText = suggestions.toString();
      }
    } else {
      debugPrint('No suggestions available');
    }

    debugPrint('Final suggestions text: $suggestionsText');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final padding = isSmallScreen ? 16.0 : 24.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (rest of your existing widget code remains the same)

            CommonCard(
              // Remove any default padding from CommonCard if possible
              padding: EdgeInsets
                  .zero, // Add this if CommonCard has a padding parameter
              margin: EdgeInsets.zero, // Add this if needed
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isMobile =
                      constraints.maxWidth < 600; // Adjust breakpoint as needed

                  return IntrinsicHeight(
                    child: Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Content Section (Top on mobile, Left on desktop)
                        Expanded(
                          flex: isMobile
                              ? 0
                              : 60, // Don't flex vertically on mobile
                          child: Padding(
                            padding:
                                EdgeInsets.all(isMobile ? padding : padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isSuitable
                                          ? Icons.check_circle
                                          : Icons.warning,
                                      color: isSuitable
                                          ? Colors.green
                                          : Colors.orange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isSuitable
                                          ? 'Suitable Crop'
                                          : 'Not Suitable',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSuitable
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: isMobile ? 18 : 24,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Confidence:',
                                  '${(suitabilityResult['confidence'] * 100).toStringAsFixed(1)}%',
                                ),
                                _buildInfoRow(
                                  'Models Used:',
                                  suitabilityResult['model_used'].join(', '),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Image Section (Bottom on mobile, Right on desktop)
                        if (suitabilityResult['image_url'] != null) ...[
                          Expanded(
                            flex: isMobile
                                ? 0
                                : 40, // Don't flex vertically on mobile
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: isMobile
                                    ? 150
                                    : 0, // Set minimum height for mobile
                              ),
                              child: ClipRRect(
                                borderRadius: isMobile
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      )
                                    : BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                child: Image.network(
                                  suitabilityResult['image_url'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🟦 Parameter Analysis
            CommonCard(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parameter Analysis',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 20 : 24,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (isSmallScreen) ...[
                      // Mobile/small screen view - single column
                      ...parametersAnalysis.entries.map((entry) {
                        final param = entry.key;
                        final analysis = entry.value;
                        return _buildParameterRow(
                          context,
                          parameter: param,
                          current: analysis['current'],
                          min: analysis['ideal_min'],
                          max: analysis['ideal_max'],
                          status: analysis['status'],
                          isSmallScreen: isSmallScreen,
                        );
                      }),
                    ] else ...[
                      // Desktop view - two columns
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First column (half of the parameters)
                          Expanded(
                            child: Column(
                              children: parametersAnalysis.entries
                                  .take((parametersAnalysis.length / 2).ceil())
                                  .map((entry) {
                                final param = entry.key;
                                final analysis = entry.value;
                                return _buildParameterRow(
                                  context,
                                  parameter: param,
                                  current: analysis['current'],
                                  min: analysis['ideal_min'],
                                  max: analysis['ideal_max'],
                                  status: analysis['status'],
                                  isSmallScreen: isSmallScreen,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Second column (remaining parameters)
                          Expanded(
                            child: Column(
                              children: parametersAnalysis.entries
                                  .skip((parametersAnalysis.length / 2).ceil())
                                  .map((entry) {
                                final param = entry.key;
                                final analysis = entry.value;
                                return _buildParameterRow(
                                  context,
                                  parameter: param,
                                  current: analysis['current'],
                                  min: analysis['ideal_min'],
                                  max: analysis['ideal_max'],
                                  status: analysis['status'],
                                  isSmallScreen: isSmallScreen,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (deficientParams.isNotEmpty) ...[
              const SizedBox(height: 16),
              CommonCard(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Icon(
                              Icons
                                  .auto_awesome_outlined, // M3-style lightbulb icon
                              size: isSmallScreen ? 24 : 28,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Improvement Suggestions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 20 : 24,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Content Area
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: suggestionsText.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestionsText,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: onGetSuggestions,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isSmallScreen ? 14 : 16,
                                          horizontal: 24,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: isLoadingSuggestions
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Get Improvement Suggestions',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 15 : 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  if (!isSmallScreen) const SizedBox(height: 8),
                                  if (!isSmallScreen)
                                    Text(
                                      'Get AI-powered suggestions to improve your results',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Disclaimer
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                suitabilityResult['disclaimer'] ??
                    'AI suggestions should be verified with local agricultural experts',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  // ... (rest of your existing helper methods remain the same)

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(
    BuildContext context, {
    required String parameter,
    required double current,
    required double min,
    required double max,
    required String status,
    required bool isSmallScreen,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'low':
        statusColor = Colors.orange;
        statusIcon = Icons.arrow_downward;
        break;
      case 'high':
        statusColor = Colors.red;
        statusIcon = Icons.arrow_upward;
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _formatParameterName(parameter),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Current: ${current.toStringAsFixed(1)} (Ideal: ${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)})',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _calculateProgressValue(current, min, max),
          minHeight: 6,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressBarColor(current, min, max)),
        ),
      ]),
    );
  }

  String _formatParameterName(String param) {
    final Map<String, String> paramNames = {
      'N': 'Nitrogen (N)',
      'P': 'Phosphorous (P)',
      'K': 'Potassium (K)',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'ph': 'pH Level',
      'rainfall': 'Rainfall',
    };
    return paramNames[param] ?? param;
  }

  double _calculateProgressValue(double current, double min, double max) {
    final range = max - min;
    if (current < min) return 0.3;
    if (current > max) return 1.0;
    return (current - min) / range;
  }

  Color _getProgressBarColor(double current, double min, double max) {
    if (current < min * 0.8) return Colors.orange[300]!; // Young fruit
    if (current > max * 1.2) return Colors.red[400]!; // Ripe tomato
    if (current < min || current > max)
      return Colors.deepOrange[300]!; // Developing fruit
    return Colors.green[600]!; // Healthy foliage
  }
}
