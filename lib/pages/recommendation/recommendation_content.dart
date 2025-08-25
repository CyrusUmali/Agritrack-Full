import 'package:flareline/pages/recommendation/chatbot/chatbot_content.dart';
import 'package:flareline/pages/recommendation/chatbot/chatbot_page.dart';
import 'package:flareline/pages/recommendation/requirement.dart';
import 'package:flareline/pages/recommendation/requirement_page.dart';
import 'package:flareline/pages/recommendation/suitability/suitability_page.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'recommendation_inputs.dart';
import 'recommendation_results.dart';
import 'recommendation_model.dart';

class RecommendationContent extends StatefulWidget {
  const RecommendationContent({super.key});

  @override
  RecommendationContentState createState() => RecommendationContentState();
}

class RecommendationContentState extends State<RecommendationContent> {
  final RecommendationModel model = RecommendationModel();
  final GlobalKey _navigationMenuKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isTablet = MediaQuery.of(context).size.width < 900;

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
                // Responsive Header
                _buildResponsiveHeader(isMobile, isTablet),

                const SizedBox(height: 24),

                // Model selection card
                _buildModelSelectionCard(),

                const SizedBox(height: 24),

                // Input parameters card
                _buildInputParametersCard(isMobile),

                // Results
                if (model.predictionResult != null &&
                    model.predictionResult!['recommendations'] != null &&
                    model.predictionResult!['recommendations'].isNotEmpty) ...[
                  const SizedBox(height: 24),
                  RecommendationResults(
                      predictionResult: model.predictionResult!),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isMobile, bool isTablet) {
    // Navigation function
    void _navigateToRequirements() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RequirementPage(),
        ),
      );
    }

    void _showNavigationMenu() async {
      final RenderBox? renderBox =
          _navigationMenuKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
      final Size buttonSize = renderBox.size;

      final result = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          buttonPosition.dx,
          buttonPosition.dy + buttonSize.height,
          buttonPosition.dx + 200,
          buttonPosition.dy + buttonSize.height + 100,
        ),
        items: [
          const PopupMenuItem(
            value: 'back',
            child: ListTile(
              title: Text('Chatbot'),
            ),
          ),
          const PopupMenuItem(
            value: 'suitability',
            child: ListTile(
              title: Text('Crop Suitability'),
            ),
          ),
        ],
      );

      if (result == 'back') {
        // Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const ChatbotPage(), // Change to your desired page
          ),
        );
      } else if (result == 'suitability') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuitabilityPage()),
        );
      }
    }

    // For desktop view (when neither mobile nor tablet)
    if (!isMobile && !isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Text on left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crop Recommendation',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      // color: const Color.fromARGB(255, 1, 1, 1),
                    ),
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: 'Navigation Options',
                child: IconButton(
                  key: _navigationMenuKey,
                  icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(-1.0, 1.0), // Flip horizontally (mirror effect)
                    child: const Icon(
                      Icons.keyboard_return,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    _showNavigationMenu();

                    // if (!mounted)
                    //   return; // Check if the widget is still in the tree
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const SuitabilityPage()),
                    // );
                  },
                  splashRadius: 16, // Smaller splash effect
                  padding: EdgeInsets.zero, // Remove extra padding
                ),
              ),
            ],
          ),

          // Tooltip with InkWell for better hover effects
          Tooltip(
            message: 'View Requirements',
            child: InkWell(
              onTap: _navigateToRequirements,
              borderRadius: BorderRadius.circular(50),
              hoverColor: Colors.grey.withOpacity(0.1), // Gray hover effect
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[500]!, // Medium gray border
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: 30,
                  color: Colors.grey[700], // Dark gray icon
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For mobile/tablet view (column layout)
    return Column(
      children: [
        // Title Text

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Recommendation',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 24 : 28,
                    color: const Color.fromARGB(255, 1, 1, 1),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flipped Return Icon
                Tooltip(
                  message: 'Navigation Options',
                  child: IconButton(
                    key: _navigationMenuKey,
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(-1.0, 1.0), // Flip horizontally (mirror effect)
                      child: const Icon(
                        Icons.keyboard_return,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () {
                      _showNavigationMenu();

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const SuitabilityPage()),
                      // );
                    },
                    splashRadius: 16, // Smaller splash effect
                    padding: EdgeInsets.zero, // Remove extra padding
                  ),
                ),

                // Tooltip Circular Button
                Tooltip(
                  message: 'View Requirements',
                  child: InkWell(
                    onTap: _navigateToRequirements,
                    borderRadius: BorderRadius.circular(50),
                    hoverColor: Colors.grey.withOpacity(0.1),
                    child: Container(
                      width: 25,
                      height: 25,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[500]!,
                          width: 1,
                        ),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModelSelectionCard() {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Model',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  // color: const Color.fromARGB(255, 18, 18, 18),
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: model.selectedModel,
            
            items: model.models.keys.map((String modelName) {
              return DropdownMenuItem<String>(
                value: modelName,
                child: Text(
                  modelName,
                  style: TextStyle( 
                    fontSize: 14, 
                    color: Theme.of(context).colorScheme.onSurface,  
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                model.selectedModel = newValue!;
                model.modelAccuracy =
                    'Accuracy: ${(model.models[newValue]!['accuracy']! * 100).toStringAsFixed(2)}%';
              });
            },
            style: TextStyle(
              fontSize: 14,
              // color: Colors.grey[800],
                color: Theme.of(context).colorScheme.onSurface, 
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 0.5),
              ),
              filled: true, 
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              // hintStyle: TextStyle(color: Colors.grey[600]),
            ),
            dropdownColor: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
            iconSize: 24,
          ),
          // if (model.modelAccuracy != null) ...[
          //   const SizedBox(height: 8),
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          //     decoration: BoxDecoration(
          //       color: Colors.green[50],
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Text(
          //       model.modelAccuracy!,
          //       style: TextStyle(
          //         color: Colors.green[800],
          //         fontSize: 14,
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    ));
  }

  Widget _buildInputParametersCard(bool isMobile) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'Enter Environmental Parameters',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 20 : 24,
                    color: Colors.grey[800],
                  ),
            ),
          ),
          const SizedBox(height: 16),
          RecommendationInputs(
            model: model,
            isMobile: isMobile,
            onChanged: () => setState(() {}), // Add this callback
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  model.isLoading =
                      true; // Manually set loading state before prediction
                });

                await model.predictCrop();

                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.1,
                ),
                minimumSize: const Size(64, 48),
              ),
              child: model.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Predict',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ));
  }
}
