import 'package:flareline/pages/products/product_profile.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';

class RecommendationResults extends StatelessWidget {
  final Map<String, dynamic> predictionResult;

  const RecommendationResults({
    super.key,
    required this.predictionResult,
  });
  @override
  Widget build(BuildContext context) {
    final recommendations = predictionResult['recommendations'] as List;
    final primaryRecommendation = recommendations[0];
    final secondaryRecommendations =
        recommendations.length > 1 ? recommendations.sublist(1) : <dynamic>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final padding = isSmallScreen ? 16.0 : 24.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟩 Recommended Crop
            Stack(
              children: [
                CommonCard(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: _buildRecommendationSection(
                      context,
                      isSmallScreen: isSmallScreen,
                      title: 'Recommended Crop',
                      recommendation: primaryRecommendation,
                      isPrimary: true,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'View Details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductProfile(product: primaryRecommendation),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // 🟦 Alternative Crops
            if (secondaryRecommendations.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    child: Text(
                      'Alternative Crops',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                            fontSize: isSmallScreen ? 20 : 24,
                          ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  if (isSmallScreen)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Row(
                        children: [
                          for (int i = 0;
                              i < secondaryRecommendations.length;
                              i++) ...[
                            Stack(
                              children: [
                                CommonCard(
                                  child: SizedBox(
                                    width: 200,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: _buildRecommendationSection(
                                        context,
                                        isSmallScreen: true,
                                        recommendation:
                                            secondaryRecommendations[i],
                                        isPrimary: false,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    icon:
                                        const Icon(Icons.open_in_new, size: 16),
                                    tooltip: 'View Details',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductProfile(
                                              product:
                                                  secondaryRecommendations[i]),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (i < secondaryRecommendations.length - 1)
                              SizedBox(width: 12), // spacing between cards
                          ],
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: secondaryRecommendations.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              CommonCard(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: _buildRecommendationSection(
                                    context,
                                    isSmallScreen: false,
                                    recommendation:
                                        secondaryRecommendations[index],
                                    isPrimary: false,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.open_in_new, size: 20),
                                  tooltip: 'View Details',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductProfile(
                                            product: secondaryRecommendations[
                                                index]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),

            SizedBox(height: 10),

            // 🟨 Additional Info
            CommonCard(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    _buildInfoRow(
                      'Total crops considered:',
                      predictionResult['total_crops_considered'].toString(),
                      isSmallScreen: isSmallScreen,
                    ),
                    if (predictionResult['confidence_threshold'] != null) ...[
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      _buildInfoRow(
                        'Confidence threshold:',
                        '${(predictionResult['confidence_threshold'] * 100).toStringAsFixed(0)}%',
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                    if (predictionResult['note'] != null) ...[
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        'Note: ${predictionResult['note']}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value,
      {required bool isSmallScreen}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(
    BuildContext context, {
    required dynamic recommendation,
    required bool isSmallScreen,
    bool isPrimary = false,
    String? title,
  }) {
    final hasWarning = recommendation['warning'] == 'low_confidence';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.green[700] : Colors.blue[700],
                  fontSize: isSmallScreen ? 20 : 24,
                ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
        ],

        // Add warning badge here
        if (hasWarning) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.orange[800]),
                SizedBox(width: 4),
                Text(
                  'Low Confidence',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
        ],

        // Crop Name and Confidence
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                recommendation['crop'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: isPrimary
                      ? (isSmallScreen ? 20 : 24)
                      : (isSmallScreen ? 18 : 20),
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.green[800] : Colors.blue[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              '${(recommendation['confidence'] * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        // Crop Image
        SizedBox(height: isSmallScreen ? 12 : 16),
        // Replace the image decoration part in _buildRecommendationSection with:
        Container(
          height: isPrimary
              ? (isSmallScreen ? 160 : 200)
              : (isSmallScreen ? 120 : 150),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            image: DecorationImage(
              image: NetworkImage(
                recommendation['image_url'] ??
                    'https://via.placeholder.com/400',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Model Votes
        SizedBox(height: isSmallScreen ? 12 : 16),
        Text(
          'Model Votes:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: isSmallScreen ? 15 : 17,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        ...List.generate(
          recommendation['supporting_models'].length,
          (index) {
            final model = recommendation['supporting_models'][index];
            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 3 : 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      model['model'],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${(model['probability'] * 100).toStringAsFixed(2)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
