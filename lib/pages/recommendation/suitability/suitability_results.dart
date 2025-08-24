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
    final confidence = suitabilityResult['confidence'] as double;

    // Process suggestions - handle both String and List<String> cases
    final suggestions = _processSuggestions(suitabilityResult['suggestions']);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final padding = isSmallScreen ? 16.0 : 24.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Main Result Card with simplified design
            _buildMainResultCard(
              context,
              isSuitable,
              confidence,
              isSmallScreen,
              padding,
            ),

            SizedBox(height: isSmallScreen ? 20 : 28),

            // 📊 Parameter Analysis Section
            _buildParameterAnalysisCard(
              context,
              parametersAnalysis,
              isSmallScreen,
              padding,
            ),

            // 💡 Suggestions Section
            if (deficientParams.isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 20 : 28),
              _buildSuggestionsCard(
                context,
                suggestions,
                deficientParams.length,
                isSmallScreen,
                padding,
              ),
            ],

            SizedBox(height: isSmallScreen ? 16 : 20),

            // 📝 Disclaimer
            _buildDisclaimer(context, isSmallScreen, padding),
          ],
        );
      },
    );
  }

  Widget _buildMainResultCard(
    BuildContext context,
    bool isSuitable,
    double confidence,
    bool isSmallScreen,
    double padding,
  ) {
    final mainColor = isSuitable ? Colors.green : Colors.orange;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSuitable ? Icons.verified : Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSuitable ? 'SUITABLE' : 'NEEDS IMPROVEMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!isSuitable) _buildWarningBadge(isSmallScreen),
              ],
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Confidence Display
            _buildConfidenceDisplay(
              context,
              confidence,
              mainColor,
              isSmallScreen,
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Models Used
            _buildModelsUsedSection(
              context,
              isSmallScreen,
            ),

            // Image if available
            if (suitabilityResult['image_url'] != null) ...[
              SizedBox(height: isSmallScreen ? 16 : 20),
              _buildImageSection(isSmallScreen),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceDisplay(
    BuildContext context,
    double confidence,
    Color mainColor,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics,
              color: mainColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence Level',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: confidence,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(confidence),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelsUsedSection(
    BuildContext context,
    bool isSmallScreen,
  ) {
    final models = suitabilityResult['model_used'] as List;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.memory,
                color: Colors.blue[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Models Used',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: models.map((model) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  model.toString(),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isMobile) {
    return Container(
      height: isMobile ? 180 : 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[200],
              child: Image.network(
                suitabilityResult['image_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.landscape,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.green[600],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay for better text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterAnalysisCard(
    BuildContext context,
    Map<String, dynamic> parametersAnalysis,
    bool isSmallScreen,
    double padding,
  ) {
    final optimalCount = parametersAnalysis.entries
        .where((e) => e.value['status'] == 'optimal')
        .length;
    final totalCount = parametersAnalysis.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.blue[600],
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Parameter Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                ),
                const Spacer(),
                // Overall score indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getOverallScoreColor(optimalCount, totalCount).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getOverallScoreColor(optimalCount, totalCount),
                    ),
                  ),
                  child: Text(
                    '${((optimalCount / totalCount) * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getOverallScoreColor(optimalCount, totalCount),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            Text(
              '$optimalCount of $totalCount parameters optimal',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Parameters grid/list
            if (isSmallScreen)
              // Mobile: Single column
              Column(
                children: parametersAnalysis.entries
                    .map((entry) => _buildParameterCard(
                          context,
                          parameter: entry.key,
                          current: entry.value['current'],
                          min: entry.value['ideal_min'],
                          max: entry.value['ideal_max'],
                          status: entry.value['status'],
                          isSmallScreen: isSmallScreen,
                        ))
                    .toList(),
              )
            else
              // Desktop: Two-column grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.3,
                ),
                itemCount: parametersAnalysis.length,
                itemBuilder: (context, index) {
                  final entry = parametersAnalysis.entries.elementAt(index);
                  return _buildParameterCard(
                    context,
                    parameter: entry.key,
                    current: entry.value['current'],
                    min: entry.value['ideal_min'],
                    max: entry.value['ideal_max'],
                    status: entry.value['status'],
                    isSmallScreen: false,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(
    BuildContext context, {
    required String parameter,
    required double current,
    required double min,
    required double max,
    required String status,
    required bool isSmallScreen,
  }) {
    final statusInfo = _getStatusInfo(status);
    final progressValue = _calculateProgressValue(current, min, max);
    final progressColor = _getProgressBarColor(current, min, max);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusInfo.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                _getParameterIcon(parameter),
                color: statusInfo.color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatParameterName(parameter),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusInfo.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Current value display
          Row(
            children: [
              Text(
                'Current: ',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${current.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: statusInfo.color,
                ),
              ),
              Text(
                ' (${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressValue,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard(
    BuildContext context,
    List<String> suggestions,
    int deficientParamsCount,
    bool isSmallScreen,
    double padding,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.blue[600],
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Improvement Suggestions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                ),
                const Spacer(),
                if (deficientParamsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      '$deficientParamsCount',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            Text(
              '$deficientParamsCount parameters need attention',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Content area
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.all(16),
              child: suggestions.isNotEmpty
                  ? _buildSuggestionsContent(suggestions, context, isSmallScreen)
                  : _buildGetSuggestionsButton(context, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context, bool isSmallScreen, double padding) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suitabilityResult['disclaimer'] ??
                  'AI suggestions should be verified with local agricultural experts',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBadge(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Needs Attention',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final lines = section.split('\n');

        return Container(
          margin: EdgeInsets.only(bottom: index < suggestions.length - 1 ? 12 : 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Text(
                section,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Build the "Get Suggestions" button
  Widget _buildGetSuggestionsButton(BuildContext context, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 48 : 52,
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoadingSuggestions ? null : onGetSuggestions,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoadingSuggestions)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Get AI Suggestions',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods and utilities
  ({Color color, Color backgroundColor, Color borderColor}) _getStatusInfo(String status) {
    switch (status) {
      case 'low':
        return (
          color: Colors.orange[600]!,
          backgroundColor: Colors.orange[50]!,
          borderColor: Colors.orange[200]!,
        );
      case 'high':
        return (
          color: Colors.red[600]!,
          backgroundColor: Colors.red[50]!,
          borderColor: Colors.red[200]!,
        );
      default:
        return (
          color: Colors.green[600]!,
          backgroundColor: Colors.green[50]!,
          borderColor: Colors.green[200]!,
        );
    }
  }

  IconData _getParameterIcon(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'n':
      case 'nitrogen':
        return Icons.eco;
      case 'p':
      case 'phosphorous':
        return Icons.scatter_plot;
      case 'k':
      case 'potassium':
        return Icons.biotech;
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'ph':
        return Icons.science;
      case 'rainfall':
        return Icons.cloud;
      default:
        return Icons.analytics;
    }
  }

  Color _getOverallScoreColor(int optimal, int total) {
    final percentage = optimal / total;
    if (percentage >= 0.8) return Colors.green[600]!;
    if (percentage >= 0.6) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green[600]!;
    if (confidence >= 0.6) return Colors.orange[600]!;
    return Colors.red[600]!;
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
    if (range == 0) return 1.0;
    if (current < min) return (current / min).clamp(0.0, 0.3);
    if (current > max) return ((current - max) / max + 1.0).clamp(0.7, 1.0);
    return ((current - min) / range).clamp(0.3, 0.7);
  }

  Color _getProgressBarColor(double current, double min, double max) {
    if (current < min * 0.8) return Colors.orange[400]!;
    if (current > max * 1.2) return Colors.red[500]!;
    if (current < min || current > max) return Colors.deepOrange[400]!;
    return Colors.green[600]!;
  }
}