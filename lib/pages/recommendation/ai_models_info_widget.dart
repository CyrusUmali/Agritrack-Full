// lib/pages/recommendation/ai_models_info_widget.dart

import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class AiModelsInfoWidget {
  static void show({
    required BuildContext context,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth < 600 ? 16 : 24),
                  child: Material(
                    type: MaterialType.transparency,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth < 600 ? screenWidth * 0.92 : 650,
                        maxHeight: MediaQuery.of(context).size.height * 0.85,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).cardTheme.color ?? Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const AiModelsInfoContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AiModelsInfoContent extends StatefulWidget {
  const AiModelsInfoContent({super.key});

  @override
  State<AiModelsInfoContent> createState() => _AiModelsInfoContentState();
}

class _AiModelsInfoContentState extends State<AiModelsInfoContent> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _models = [
    {
      'title': 'Decision Tree',
      'icon': Icons.account_tree,
      'color': Color(0xFF10B981),
      'description': 'Like choosing crops step by step',
      'explanation':
          'Imagine deciding what to plant by asking simple questions one after another:\n\n• Is the soil nitrogen high? → Yes/No\n• Is rainfall above 500mm? → Yes/No\n• Is temperature warm? → Yes/No\n\nEach answer leads to the next question until we find the best crop.',
      'analogy':
          'Like following a recipe: check ingredients, then steps, until dish is ready.',
      'bestFor': 'Easy to understand decisions',
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
    },
    {
      'title': 'Random Forest',
      'icon': Icons.forest,
      'color': Color(0xFF3B82F6),
      'description': 'Many experts voting together',
      'explanation':
          'This is like asking many experienced farmers for their opinion, then choosing the crop most farmers recommend.\n\nEach "farmer" (decision tree) looks at your land differently and votes for the best crop.',
      'analogy':
          'Like a farmers\' committee - more reliable than one person\'s opinion.',
      'bestFor': 'Most accurate recommendations',
      'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
    },
    {
      'title': 'Logistic Regression',
      'icon': Icons.trending_up,
      'color': Color(0xFFF59E0B),
      'description': 'Weighing what matters most',
      'explanation':
          'This method learns which factors are most important for each crop:\n\n• Soil pH might be very important for tomatoes\n• Rainfall might be crucial for rice\n• Temperature might matter most for wheat\n\nIt then calculates the best match for your conditions.',
      'analogy':
          'Like giving scores to different factors and picking the highest score.',
      'bestFor': 'Understanding which factors matter most',
      'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
    },
    {
      'title': 'XGBoost',
      'icon': Icons.rocket_launch,
      'color': Color(0xFF8B5CF6),
      'description': 'Smart learning from mistakes',
      'explanation':
          'This is our most advanced method that learns from its own mistakes.\n\nIt starts with basic recommendations, then improves by focusing on cases it got wrong previously, getting smarter with each round.',
      'analogy':
          'Like a student who reviews wrong answers to improve in next test.',
      'bestFor': 'Highest accuracy with complex patterns',
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    },
  ];

  void _nextPage() {
    if (_currentPage < _models.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with gradient
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3B82F6).withOpacity(0.1),
                Color(0xFF8B5CF6).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.psychology, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How Our AI Models Work',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                    ),
                    Text(
                      'Understanding crop recommendations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Page View
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _models.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final model = _models[index];
              return _buildModelPage(context, model, isDark);
            },
          ),
        ),

        // Footer with navigation - FIXED OVERFLOW
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_models.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: isActive
                          ? LinearGradient(
                              colors: _models[index]['gradient'],
                            )
                          : null,
                      color: isActive
                          ? null
                          : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Navigation buttons - FIXED: Wrap in Flexible to prevent overflow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - Previous button or empty space
                  SizedBox(
                    width: 100,
                    child: _currentPage > 0
                        ? ButtonWidget(
                            btnText: 'Previous',
                            onTap: _previousPage,
                            textColor: FlarelineColors.darkBlackText,
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Center - Page counter
                  Text(
                    '${_currentPage + 1} / ${_models.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),

                  // Right side - Next/Close button
                  SizedBox(
                    width: 100,
                    child: ButtonWidget(
                      btnText:
                          _currentPage == _models.length - 1 ? 'Close' : 'Next',
                      onTap: _currentPage == _models.length - 1
                          ? () => Navigator.of(context).pop()
                          : _nextPage,
                      type: ButtonType.primary.type,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelPage(
      BuildContext context, Map<String, dynamic> model, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model header with icon and title
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: model['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: model['color'].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    model['icon'],
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  model['title'],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        model['color'].withOpacity(0.15),
                        model['color'].withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    model['description'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: model['color'],
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Explanation section
          _buildSection(
            context,
            'How it works',
            Icons.lightbulb_outline,
            model['explanation'],
            model['color'],
            isDark,
          ),

          const SizedBox(height: 20),

          // Analogy section
          _buildSection(
            context,
            'Simple analogy',
            Icons.emoji_objects,
            model['analogy'],
            model['color'],
            isDark,
          ),

          const SizedBox(height: 20),

          // Best for section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  model['color'].withOpacity(0.1),
                  model['color'].withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: model['color'].withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: model['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.star, color: model['color'], size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best for',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: model['color'],
                                  fontSize: 15,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        model['bestFor'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[800],
                              fontSize: 15,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
    Color accentColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontSize: 14.5,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }
}
