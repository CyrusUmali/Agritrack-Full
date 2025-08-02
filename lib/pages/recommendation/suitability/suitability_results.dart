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

    // Process suggestions - handle both String and List<String> cases
    final suggestions = _processSuggestions(suitabilityResult['suggestions']);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final padding = isSmallScreen ? 16.0 : 24.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Result Card with Image
            CommonCard(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return IntrinsicHeight(
                    child: Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Content Section
                        Expanded(
                          flex: isMobile ? 0 : 60,
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

                        // Image Section
                        if (suitabilityResult['image_url'] != null) ...[
                          Expanded(
                            flex: isMobile ? 0 : 40,
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: isMobile ? 150 : 0,
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

            // Parameter Analysis Section
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
                      // Mobile view - single column
                      ...parametersAnalysis.entries
                          .map((entry) => _buildParameterRow(
                                context,
                                parameter: entry.key,
                                current: entry.value['current'],
                                min: entry.value['ideal_min'],
                                max: entry.value['ideal_max'],
                                status: entry.value['status'],
                                isSmallScreen: isSmallScreen,
                              )),
                    ] else ...[
                      // Desktop view - two columns
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                children: parametersAnalysis.entries
                                    .take(
                                        (parametersAnalysis.length / 2).ceil())
                                    .map((entry) => _buildParameterRow(
                                          context,
                                          parameter: entry.key,
                                          current: entry.value['current'],
                                          min: entry.value['ideal_min'],
                                          max: entry.value['ideal_max'],
                                          status: entry.value['status'],
                                          isSmallScreen: isSmallScreen,
                                        ))
                                    .toList()),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                                children: parametersAnalysis.entries
                                    .skip(
                                        (parametersAnalysis.length / 2).ceil())
                                    .map((entry) => _buildParameterRow(
                                          context,
                                          parameter: entry.key,
                                          current: entry.value['current'],
                                          min: entry.value['ideal_min'],
                                          max: entry.value['ideal_max'],
                                          status: entry.value['status'],
                                          isSmallScreen: isSmallScreen,
                                        ))
                                    .toList()),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Suggestions Section
            if (deficientParams.isNotEmpty) ...[
              const SizedBox(height: 16),
              CommonCard(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            size: isSmallScreen ? 24 : 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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

                      // Content
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
                        child: suggestions.isNotEmpty
                            ? _buildSuggestionsContent(
                                suggestions, context, isSmallScreen)
                            : _buildGetSuggestionsButton(
                                context, isSmallScreen),
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

  // Helper method to process suggestions
  List<String> _processSuggestions(dynamic suggestions) {
    if (suggestions == null) return [];
    if (suggestions is List) return suggestions.whereType<String>().toList();
    if (suggestions is String) return [suggestions];
    return [suggestions.toString()];
  }

  // Build suggestions content
  Widget _buildSuggestionsContent(
      List<String> suggestions, BuildContext context, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: suggestions.map((section) {
          // Split section into lines
          final lines = section.split('\n');
          // Find the header (line that starts with "- " and ends with ":")
          final headerIndex = lines.indexWhere((line) =>
              line.trim().startsWith('- ') && line.trim().endsWith(':'));

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (headerIndex != -1)
                  Text(
                    lines[headerIndex]
                        .substring(2, lines[headerIndex].length - 1)
                        .trim(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                // Content
                Padding(
                  padding: EdgeInsets.only(top: headerIndex != -1 ? 8 : 0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      children:
                          _buildFormattedSectionContent(lines, headerIndex),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Build formatted content for each suggestion section
  List<TextSpan> _buildFormattedSectionContent(
      List<String> lines, int headerIndex) {
    List<TextSpan> spans = [];
    bool skipHeader = headerIndex != -1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Skip the header line if we've already processed it
      if (skipHeader && i == headerIndex) continue;

      // Sub-bullet points
      if (line.startsWith('    - ')) {
        spans.add(TextSpan(
          text: '  • ${line.substring(6).trim()}\n',
          style: const TextStyle(height: 1.5),
        ));
      }
      // Additional indented content
      else if (line.startsWith('    ')) {
        spans.add(TextSpan(
          text: '    ${line.substring(4).trim()}\n',
          style: const TextStyle(height: 1.4, fontStyle: FontStyle.italic),
        ));
      }
      // Regular content
      else {
        spans.add(TextSpan(
          text: '$line\n',
          style: const TextStyle(height: 1.5),
        ));
      }
    }

    return spans;
  }

  // Build the "Get Suggestions" button
  Widget _buildGetSuggestionsButton(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onGetSuggestions,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 14 : 16,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoadingSuggestions
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Get Improvement Suggestions',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      color: Colors.white,
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
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
      ],
    );
  }

  // Existing helper methods (unchanged)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, softWrap: true)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
              ), // <- missing closing parenthesis was here
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
          ]),
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
        ],
      ),
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
    if (current < min * 0.8) return Colors.orange[300]!;
    if (current > max * 1.2) return Colors.red[400]!;
    if (current < min || current > max) return Colors.deepOrange[300]!;
    return Colors.green[600]!;
  }
}
