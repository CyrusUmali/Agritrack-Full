import 'package:flareline/pages/recommendation/chatbot/chatbot_page.dart';
import 'package:flareline/pages/recommendation/recommendation_page.dart';
import 'package:flareline/pages/recommendation/requirement_page.dart';
import 'package:flareline/pages/recommendation/suitability/suitabilty_model.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flareline/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'suitability_inputs.dart';
import 'suitability_results.dart';

class SuitabilityContent extends StatefulWidget {
  const SuitabilityContent({super.key});

  @override
  SuitabilityContentState createState() => SuitabilityContentState();
}

class SuitabilityContentState extends State<SuitabilityContent> {
  final GlobalKey _navigationMenuKey = GlobalKey();

  // Remove the local languageProvider and model declarations
  SuitabilityModel? model;

  final List<String> availableCrops = [
    "ampalaya",
    "apple",
    "banana",
    "cacao",
    "calamansi",
    "cassava",
    "coconut",
    "durian",
    "eggplant",
    "gabi",
    "ginger",
    "grapes",
    "guyabano",
    "jackfruit",
    "lanzones",
    "maize",
    "mango",
    "mungbean",
    "mustard",
    "okra",
    "onion",
    "orange",
    "oyster mushroom",
    "papaya",
    "patola",
    "pechay",
    "pineapple",
    "radish",
    "rambutan",
    "rice",
    "sigarilyas",
    "sili panigang",
    "sili tingala",
    "snap bean",
    "squash",
    "string bean",
    "sweet potato",
    "tomato",
    "ube",
    "upo",
    "watermelon",
  ];

  void _navigateToRequirements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequirementPage(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize model with the provider from context
    if (model == null) {
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      model = SuitabilityModel(languageProvider: languageProvider);
      model!.addListener(_onModelChanged);
    }
  }

  @override
  void dispose() {
    model?.removeListener(_onModelChanged);
    super.dispose();
  }

  void _onModelChanged() {
    if (mounted) {
      setState(() {});
    }
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
          value: 'recommendation',
          child: ListTile(
            title: Text('Crop Recommendation'),
          ),
        ),
      ],
    );

    if (result == 'back') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatbotPage(),
        ),
      );
    } else if (result == 'recommendation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecommendationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to language changes
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        print(
            'Current language in SuitabilityContent: ${languageProvider.currentLanguageCode}');

        if (model == null)
          return const Center(child: CircularProgressIndicator());

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
                    _buildResponsiveHeader(isMobile, isTablet),
                    const SizedBox(height: 24),
                    _buildCropSelectionDropdown(),
                    const SizedBox(height: 10),
                    _buildModelSelectionCard(),
                    const SizedBox(height: 24),
                    _buildInputParametersCard(isMobile),
                    if (model!.isLoading) ...[
                      const SizedBox(height: 24),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (model!.suitabilityResult != null &&
                        model!.suitabilityResult!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      SuitabilityResults(
                        suitabilityResult: model!.suitabilityResult!,
                        onGetSuggestions: () async {
                          try {
                            // Convert to List<String> explicitly
                            final deficientParams = (model!.suitabilityResult![
                                    'parameters_analysis'] as Map)
                                .entries
                                .where((e) => e.value['status'] != 'optimal')
                                .map((e) => e.key.toString())
                                .toList();

                            await model!.getSuggestionsStream(
                              deficientParams,
                              languageCode: languageProvider
                                  .currentLanguageCode, // This will now get the updated value
                            );
                          } catch (e) {
                            ToastHelper.showErrorToast(
                              'Error: ${e.toString()}',
                              context,
                            );
                          }
                        },
                        isLoadingSuggestions: model!.isStreamingSuggestions,
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCropSelectionDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Crop',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: const Color.fromARGB(255, 18, 18, 18),
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: model!.selectedCrop,
              hint: const Text('Choose a crop'),
              items: availableCrops.map((String crop) {
                return DropdownMenuItem<String>(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  model!.selectedCrop = newValue;
                  model!.suitabilityResult = null;
                });
              },
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
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
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
                    color: const Color.fromARGB(255, 18, 18, 18),
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: model!.selectedModel,
              items: model!.models.keys.map((String modelName) {
                return DropdownMenuItem<String>(
                  value: modelName,
                  child: Text(modelName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  model!.selectedModel = newValue!;
                  model!.modelAccuracy = newValue == 'All Models'
                      ? 'Ensemble average will be calculated'
                      : 'Accuracy: ${(model!.models[newValue]!['accuracy']! * 100).toStringAsFixed(2)}%';
                });
              },
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
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputParametersCard(bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Enter Environmental Parameters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 20 : 24,
                  ),
            ),
            const SizedBox(height: 16),
            SuitabilityInputs(
              model: model!,
              isMobile: isMobile,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: model!.selectedCrop == null
                    ? null
                    : () async {
                        try {
                          setState(() {
                            model!.isLoading = true;
                          });

                          await model!.checkSuitability();
                        } catch (e) {
                          ToastHelper.showErrorToast(
                            'Error: $e',
                            context,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      model!.selectedCrop == null ? Colors.grey : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Check Suitability',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            if (model!.suitabilityResult != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    model!.suitabilityResult = null;
                  });
                },
                child: const Text('Check Another Configuration'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isMobile, bool isTablet) {
    if (!isMobile && !isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crop Suitability',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: const Color.fromARGB(255, 1, 1, 1),
                    ),
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: 'Navigation Options',
                child: IconButton(
                  key: _navigationMenuKey,
                  icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0),
                    child: const Icon(
                      Icons.keyboard_return,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: _showNavigationMenu,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          Tooltip(
            message: 'More information',
            child: InkWell(
              onTap: _navigateToRequirements,
              borderRadius: BorderRadius.circular(50),
              hoverColor: Colors.grey.withOpacity(0.1),
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[500]!,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: 30,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Suitability ',
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
                Tooltip(
                  message: 'Navigation Options',
                  child: IconButton(
                    key: _navigationMenuKey,
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: const Icon(
                        Icons.keyboard_return,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: _showNavigationMenu,
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Tooltip(
                  message: 'More information',
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
}
