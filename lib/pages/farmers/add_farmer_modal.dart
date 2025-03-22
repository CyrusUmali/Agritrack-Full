import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class AddFarmerModal {
  static void show({
    required BuildContext context,
    required Function(String name, String email, String password, String role)
        onUserAdded,
  }) {
    // Controllers for the form fields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = 'farmer'; // Default role

    // Get screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    ModalDialog.show(
      context: context,
      title: 'Add New User',
      showTitle: true,
      showTitleDivider: true,
      modalType: screenWidth < 600 ? ModalType.small : ModalType.medium,
      onCancelTap: () {
        Navigator.of(context).pop(); // Close the modal
      },
      onSaveTap: () {
        // Validate and collect data
        final String name = nameController.text.trim();
        final String email = emailController.text.trim();
        final String password = passwordController.text.trim();

        if (name.isEmpty || email.isEmpty || password.isEmpty) {
          // Show validation error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields')),
          );
          return;
        }

        // Call the callback with the new user data
        onUserAdded(name, email, password, selectedRole);
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
                labelText: 'Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Email Field
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Password Field
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: screenWidth < 600 ? 8.0 : 16.0),

            // Role Dropdown
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth < 600 ? 10.0 : 16.0,
                  horizontal: 10.0,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'officer', child: Text('Officer')),
                DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  selectedRole = value;
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
                  btnText: 'Add User',
                  onTap: () {
                    // Validate and collect data
                    final String name = nameController.text.trim();
                    final String email = emailController.text.trim();
                    final String password = passwordController.text.trim();

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      // Show validation error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    // Call the callback with the new user data
                    onUserAdded(name, email, password, selectedRole);
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
