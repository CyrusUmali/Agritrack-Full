import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class AddYieldModal {
  static void show({
    required BuildContext context,
    required Function(String cropType, double yieldAmount, DateTime date)
        onYieldAdded,
  }) {
    // Controllers for the form fields
    final TextEditingController cropTypeController = TextEditingController();
    final TextEditingController yieldAmountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    // Get screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    ModalDialog.show(
      context: context,
      title: 'Add Manual Yield',
      showTitle: true,
      showTitleDivider: true,
      modalType: screenWidth < 600 ? ModalType.small : ModalType.medium,
      onCancelTap: () {
        Navigator.of(context).pop(); // Close the modal
      },
      onSaveTap: () {
        // Validate and collect data
        final String cropType = cropTypeController.text.trim();
        final String yieldAmountText = yieldAmountController.text.trim();
        final double? yieldAmount = double.tryParse(yieldAmountText);

        if (cropType.isEmpty || yieldAmount == null || yieldAmount <= 0) {
          // Show validation error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid yield details')),
          );
          return;
        }

        // Call the callback with the new yield data
        onYieldAdded(cropType, yieldAmount, selectedDate);
        Navigator.of(context).pop(); // Close the modal
      },
      child: Padding(
        padding: EdgeInsets.all(screenWidth < 600 ? 8.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crop Type Field
            TextFormField(
              controller: cropTypeController,
              decoration: const InputDecoration(
                labelText: 'Crop Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Yield Amount Field
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
                        text: "${selectedDate.toLocal()}".split(' ')[0]),
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
                    Navigator.of(context).pop(); // Close the modal
                  },
                ),
              ),
              SizedBox(width: screenWidth < 600 ? 10 : 20),
              SizedBox(
                width: screenWidth < 600 ? 100 : 120,
                child: ButtonWidget(
                  btnText: 'Add Yield',
                  onTap: () {
                    // Validate and collect data
                    final String cropType = cropTypeController.text.trim();
                    final String yieldAmountText =
                        yieldAmountController.text.trim();
                    final double? yieldAmount =
                        double.tryParse(yieldAmountText);

                    if (cropType.isEmpty ||
                        yieldAmount == null ||
                        yieldAmount <= 0) {
                      // Show validation error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter valid yield details')),
                      );
                      return;
                    }

                    // Call the callback with the new yield data
                    onYieldAdded(cropType, yieldAmount, selectedDate);
                    Navigator.of(context).pop(); // Close the modal
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
