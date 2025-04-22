import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class AddYieldModal {
  static void show({
    required BuildContext context,
    required Function(String cropType, String farmer, String farmArea,
            double yieldAmount, DateTime date)
        onYieldAdded,
  }) {
    // Example data
    final List<String> cropTypes = ['Rice', 'Corn', 'Wheat', 'Barley'];
    final Map<String, List<String>> farmersWithFarmAreas = {
      'John Doe': ['Field A', 'Field B'],
      'Jane Smith': ['Farm X', 'Farm Y'],
      'Mark Johnson': ['Zone 1', 'Zone 2']
    };

    // Combine all farm areas for independent selection
    final List<String> allFarmAreas =
        farmersWithFarmAreas.values.expand((areas) => areas).toList();

    final TextEditingController yieldAmountController = TextEditingController();
    TextEditingController farmAreaController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedCropType;
    String? selectedFarmer;
    String? selectedFarmArea;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    const double fieldHeight = 56.0;

    // Create GlobalKeys for the Autocomplete fields
    final GlobalKey cropTypeFieldKey = GlobalKey();
    final GlobalKey farmerFieldKey = GlobalKey();
    final GlobalKey farmAreaFieldKey = GlobalKey();

    // Common options view builder for both Autocomplete fields
    Widget _buildOptionsView(BuildContext context, Function(String) onSelected,
        Iterable<String> options, GlobalKey fieldKey) {
      // Get the width of the parent Autocomplete field using the key
      final RenderBox? fieldRenderBox =
          fieldKey.currentContext?.findRenderObject() as RenderBox?;
      final double fieldWidth = fieldRenderBox?.size.width ?? 250;

      return SizedBox(
        width: fieldWidth,
        child: Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: fieldWidth,
                maxHeight: 200,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      width: fieldWidth,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    ModalDialog.show(
      context: context,
      title: 'Add Record',
      showTitle: true,
      showTitleDivider: true,
      modalType: isSmallScreen ? ModalType.small : ModalType.medium,
      onCancelTap: () {
        Navigator.of(context).pop();
      },
      onSaveTap: () {
        final String yieldAmountText = yieldAmountController.text.trim();
        final double? yieldAmount = double.tryParse(yieldAmountText);

        if (selectedCropType == null ||
            selectedFarmer == null ||
            selectedFarmArea == null ||
            yieldAmount == null ||
            yieldAmount <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid record details')),
          );
          return;
        }

        onYieldAdded(selectedCropType!, selectedFarmer!, selectedFarmArea!,
            yieldAmount, selectedDate);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ComboBox-like widget for Crop Type
              SizedBox(
                height: fieldHeight,
                child: Autocomplete<String>(
                  key: cropTypeFieldKey, // Assign key to the Autocomplete
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return cropTypes;
                    }
                    return cropTypes.where((crop) => crop
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String value) {
                    selectedCropType = value;
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return _buildOptionsView(
                        context, onSelected, options, cropTypeFieldKey);
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      key: ValueKey('crop_type_field'),
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Crop Type',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 16.0),

              // ComboBox-like widget for Farmers
              SizedBox(
                height: fieldHeight,
                child: Autocomplete<String>(
                  key: farmerFieldKey,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return farmersWithFarmAreas.keys.toList();
                    }
                    return farmersWithFarmAreas.keys.where((farmer) => farmer
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String value) {
                    selectedFarmer = value;
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return _buildOptionsView(
                        context, onSelected, options, farmerFieldKey);
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      key: ValueKey('farmer_field'),
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Farmer',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: isSmallScreen ? 8.0 : 16.0),

              // Farm Area as Autocomplete (now independent of farmer selection)
              SizedBox(
                height: fieldHeight,
                child: Autocomplete<String>(
                  key: farmAreaFieldKey,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return allFarmAreas;
                    }
                    return allFarmAreas.where((area) => area
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String value) {
                    selectedFarmArea = value;
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return _buildOptionsView(
                        context, onSelected, options, farmAreaFieldKey);
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    farmAreaController = textEditingController;

                    return TextFormField(
                      key: ValueKey('farm_area_field'),
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Farm Area',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 16.0),

              // Yield Amount Input
              SizedBox(
                height: fieldHeight,
                child: TextFormField(
                  controller: yieldAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Yield Amount (kg)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 16.0),

              // Date Picker
              SizedBox(
                height: fieldHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                selectedDate = pickedDate;
                              }
                            },
                          ),
                        ),
                        controller: TextEditingController(
                          text: "${selectedDate.toLocal()}".split(' ')[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10.0 : 20.0,
          vertical: 10.0,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: isSmallScreen ? 100 : 120,
                child: ButtonWidget(
                  btnText: 'Cancel',
                  textColor: FlarelineColors.darkBlackText,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 20),
              SizedBox(
                width: isSmallScreen ? 100 : 120,
                child: ButtonWidget(
                  btnText: 'Add Record',
                  onTap: () {
                    final String yieldAmountText =
                        yieldAmountController.text.trim();
                    final double? yieldAmount =
                        double.tryParse(yieldAmountText);

                    if (selectedCropType == null ||
                        selectedFarmer == null ||
                        selectedFarmArea == null ||
                        yieldAmount == null ||
                        yieldAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter valid yield details')),
                      );
                      return;
                    }

                    onYieldAdded(selectedCropType!, selectedFarmer!,
                        selectedFarmArea!, yieldAmount, selectedDate);
                    Navigator.of(context).pop();
                  },
                  type: ButtonType.primary.type,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
