import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class AddProductModal {
  static void show({
    required BuildContext context,
    required Function(String name, String description, String category)
        onProductAdded,
  }) {
    // Controllers for the form fields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'General'; // Default category

    // Get screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    ModalDialog.show(
      context: context,
      title: 'Add New Product',
      showTitle: true,
      showTitleDivider: true,
      modalType: screenWidth < 600 ? ModalType.small : ModalType.medium,
      onCancelTap: () {
        Navigator.of(context).pop(); // Close the modal
      },
      onSaveTap: () {
        // Validate and collect data
        final String name = nameController.text.trim();
        final String description = descriptionController.text.trim();

        if (name.isEmpty || description.isEmpty) {
          // Show validation error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields correctly')),
          );
          return;
        }

        // Call the callback with the new product data
        onProductAdded(name, description, selectedCategory);
        Navigator.of(context).pop(); // Close the modal
      },
      child: Padding(
        padding: EdgeInsets.all(screenWidth < 600 ? 8.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name Field
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Description Field
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(
                    value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                DropdownMenuItem(
                    value: 'Accessories', child: Text('Accessories')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
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
                  btnText: 'Add Product',
                  onTap: () {
                    // Validate and collect data
                    final String name = nameController.text.trim();
                    final String description =
                        descriptionController.text.trim();

                    if (name.isEmpty || description.isEmpty) {
                      // Show validation error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all fields correctly')),
                      );
                      return;
                    }

                    // Call the callback with the new product data
                    onProductAdded(name, description, selectedCategory);
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
