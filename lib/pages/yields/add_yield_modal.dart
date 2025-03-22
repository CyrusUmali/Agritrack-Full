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
    // Example data (this should be fetched from API or database inside the modal)
    final List<String> cropTypes = ['Rice', 'Corn', 'Wheat', 'Barley'];
    final Map<String, List<String>> farmersWithFarmAreas = {
      'John Doe': ['Field A', 'Field B'],
      'Jane Smith': ['Farm X', 'Farm Y'],
      'Mark Johnson': ['Zone 1', 'Zone 2']
    };

    final TextEditingController yieldAmountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedCropType;
    String? selectedFarmer;
    String? selectedFarmArea;

    final double screenWidth = MediaQuery.of(context).size.width;

    ModalDialog.show(
      context: context,
      title: 'Add Manual Yield',
      showTitle: true,
      showTitleDivider: true,
      modalType: screenWidth < 600 ? ModalType.small : ModalType.medium,
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
            const SnackBar(content: Text('Please enter valid yield details')),
          );
          return;
        }

        onYieldAdded(selectedCropType!, selectedFarmer!, selectedFarmArea!,
            yieldAmount, selectedDate);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.all(screenWidth < 600 ? 8.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ComboBox-like widget for Crop Type
            Autocomplete<String>(
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
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Crop Type',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                );
              },
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // ComboBox-like widget for Farmers
            Autocomplete<String>(
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
                selectedFarmArea = null; // Reset farm area when farmer changes
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Farmer',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                );
              },
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Farm Area Dropdown (dependent on selected farmer)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Farm Area',
                border: OutlineInputBorder(),
              ),
              value: selectedFarmArea,
              items: selectedFarmer != null
                  ? farmersWithFarmAreas[selectedFarmer]!
                      .map((area) => DropdownMenuItem(
                            value: area,
                            child: Text(area),
                          ))
                      .toList()
                  : [],
              onChanged: (value) {
                selectedFarmArea = value;
              },
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Yield Amount Input
            TextFormField(
              controller: yieldAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Yield Amount (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Date Picker
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
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
          ],
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600 ? 10.0 : 20.0,
          vertical: 10.0,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: screenWidth < 600 ? 100 : 120,
                child: ButtonWidget(
                  btnText: 'Cancel',
                  textColor: FlarelineColors.darkBlackText,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(width: screenWidth < 600 ? 10 : 20),
              SizedBox(
                width: screenWidth < 600 ? 100 : 120,
                child: ButtonWidget(
                  btnText: 'Add Yield',
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
