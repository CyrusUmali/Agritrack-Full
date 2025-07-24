import 'package:flareline/pages/auth/sign_up/sign_up_provider.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flareline_uikit/core/mvvm/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/mvvm/base_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SignUpWidget extends BaseWidget<SignUpProvider> {
  @override
  Widget bodyWidget(
      BuildContext context, SignUpProvider viewModel, Widget? child) {
    if (viewModel.isPendingVerification) {
      return _buildVerificationPendingScreen(context, viewModel);
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on mobile based on width (common breakpoint is 600)
          final isMobile = constraints.maxWidth < 600;

          return Stack(
            children: [
              // Background - image for desktop, white for mobile
              if (!isMobile) ...[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/loginBG2.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ] else ...[
                Container(
                  color: Colors.white, // White background for mobile
                ),
              ],

              // Main content
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 800.0,
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    padding: isMobile
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    child: Center(
                      child: CommonCard(
                        padding: EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: isMobile ? 0.0 : 40.0,
                        ),
                        borderRadius: isMobile ? 0 : 12.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/signIn');
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      color: Theme.of(context).primaryColor,
                                      size: 14.0,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 100,
                              child: Image.asset('assets/DA_image.jpg'),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "AgriTrack - Farmer Registration",
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Complete the form to register as a farmer",
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            _buildStepper(viewModel, isMobile),
                            _buildFormContent(context, viewModel, isMobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Loading indicator overlay
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepper(SignUpProvider viewModel, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        height: isMobile ? 300 : 120,
        child: Stepper(
          currentStep: viewModel.currentStep,
          onStepContinue: viewModel.nextStep,
          onStepCancel: viewModel.previousStep,
          onStepTapped: (step) => viewModel.goToStep(step),
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            return Container();
          },
          type: isMobile ? StepperType.vertical : StepperType.horizontal,
          steps: [
            Step(
              title: Text('Account',
                  style: TextStyle(fontSize: isMobile ? 14 : 16)),
              content: SizedBox.shrink(),
              isActive: viewModel.currentStep >= 0,
              state: _getStepState(viewModel, 0),
            ),
            Step(
              title: Text('Personal',
                  style: TextStyle(fontSize: isMobile ? 14 : 16)),
              content: SizedBox.shrink(),
              isActive: viewModel.currentStep >= 1,
              state: _getStepState(viewModel, 1),
            ),
            Step(
              title: Text('Household',
                  style: TextStyle(fontSize: isMobile ? 14 : 16)),
              content: SizedBox.shrink(),
              isActive: viewModel.currentStep >= 2,
              state: _getStepState(viewModel, 2),
            ),
            Step(
              title: Text('Contact',
                  style: TextStyle(fontSize: isMobile ? 14 : 16)),
              content: SizedBox.shrink(),
              isActive: viewModel.currentStep >= 3,
              state: _getStepState(viewModel, 3),
            ),
          ],
        ),
      ),
    );
  }

  StepState _getStepState(SignUpProvider viewModel, int stepIndex) {
    if (viewModel.currentStep > stepIndex) {
      return StepState.complete;
    } else if (viewModel.currentStep == stepIndex) {
      return StepState.indexed;
    } else {
      // You can return StepState.disabled for incomplete steps
      // or create a custom incomplete state if needed
      return StepState.disabled; // This shows the step as incomplete/greyed out
    }
  }

  Widget _buildFormContent(
      BuildContext context, SignUpProvider viewModel, bool isMobile) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildAccountForm(context, viewModel, isMobile);
      case 1:
        return _buildPersonalForm(context, viewModel, isMobile);
      case 2:
        return _buildHouseholdForm(context, viewModel, isMobile);
      case 3:
        return _buildContactForm(context, viewModel, isMobile);
      default:
        return Container();
    }
  }

  Widget _buildAccountForm(
      BuildContext context, SignUpProvider viewModel, bool isMobile) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          OutBorderTextFormField(
            labelText: "Email",

            hintText: "Enter your email",
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
            maxLength: 100,
            // suffixWidget: Icon(Icons.email_outlined, size: 20),
            controller: viewModel.emailController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            obscureText: true,
            labelText: "Password",
            hintText: "Enter your password",
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            maxLength: 50,
            // suffixWidget: Icon(Icons.lock_outline, size: 20),
            controller: viewModel.passwordController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            obscureText: true,
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != viewModel.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            maxLength: 50,
            // suffixWidget: Icon(Icons.lock_outline, size: 20),
            controller: viewModel.rePasswordController,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment:
                isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
            children: [
              SizedBox(
                width: isMobile ? 150 : 400, // Fixed max width for desktop
                height: 50, // Fixed height
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Next ",
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        viewModel.nextStep();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPersonalForm(
      BuildContext context, SignUpProvider viewModel, bool isMobile) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (isMobile) ...[
            Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
          ],
          OutBorderTextFormField(
            labelText: "First Name",
            hintText: "Enter your first name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'First name is required';
              }
              return null;
            },
            maxLength: 50,
            controller: viewModel.firstNameController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Middle Name",
            hintText: "Enter your middle name",
            maxLength: 50,
            controller: viewModel.middleNameController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Last Name",
            hintText: "Enter your last name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
            maxLength: 50,
            controller: viewModel.lastNameController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Name Extension (e.g. Jr, Sr)",
            hintText: "Enter name extension if applicable",
            maxLength: 10,
            controller: viewModel.extensionController,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: "Sex",
            value: viewModel.sex,
            items: ['Male', 'Female', 'Other'],
            onChanged: (value) => viewModel.sex = value,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: "Civil Status",
            value: viewModel.civilStatus,
            items: ['Single', 'Married', 'Widowed', 'Separated', 'Divorced'],
            onChanged: (value) => viewModel.civilStatus = value,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Spouse Name (if married)",
            hintText: "Enter spouse name if applicable",
            maxLength: 100,
            controller: viewModel.spouseNameController,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Back",
                    onTap: viewModel.previousStep,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Next",
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        viewModel.nextStep();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHouseholdForm(
      BuildContext context, SignUpProvider viewModel, bool isMobile) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (isMobile) ...[
            Text(
              "Household Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
          ],
          OutBorderTextFormField(
            labelText: "Household Head",
            hintText: "Enter name of household head",
            maxLength: 100,
            controller: viewModel.householdHeadController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Number of Household Members",
            hintText: "Enter total number",
            keyboardType: TextInputType.number,
            maxLength: 3,
            controller: viewModel.householdNumController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutBorderTextFormField(
                  labelText: "Male Members",
                  hintText: "Number of males",
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  controller: viewModel.maleMembersController,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutBorderTextFormField(
                  labelText: "Female Members",
                  hintText: "Number of females",
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  controller: viewModel.femaleMembersController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Mother's Maiden Name",
            hintText: "Enter your mother's maiden name",
            maxLength: 100,
            controller: viewModel.motherMaidenNameController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Religion",
            hintText: "Enter your religion",
            maxLength: 50,
            controller: viewModel.religionController,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Back",
                    onTap: viewModel.previousStep,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Next",
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        viewModel.nextStep();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactForm(
      BuildContext context, SignUpProvider viewModel, bool isMobile) {
    final _formKey = GlobalKey<FormState>();

    // Get barangay names from the local stored_polygons.dart file
    final List<String> barangayNames =
        barangays.map((b) => b['name'] as String).toList();

    // final List<String> barangayNames =
    //     viewModel.barangays?.map((b) => b['name'] as String).toList() ??
    //         [
    //           'Barangay 1', // Default fallback values if no data is loaded
    //           'Barangay 2',
    //           'Barangay 3',
    //         ];

    final List<String> sectorOptions = [
      '1:Rice',
      '2:Corn',
      '3:HVC',
      '4:Livestock',
      '5:Fishery',
      '6:Organic',
    ];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (isMobile) ...[
            Text(
              "Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
          ],
          // Dropdown Autocomplete for Barangay
          _buildDropdownAutocomplete(
            label: "Barangay",
            hintText: "Select your barangay",
            options: barangayNames,
            controller: viewModel.barangayController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Barangay is required';
              }
              if (!barangayNames.contains(value)) {
                return 'Please select a valid barangay';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),
          // Dropdown for Sector
          _buildDropdownField(
            label: "Sector",
            value: viewModel.sectorController.text.isNotEmpty
                ? viewModel.sectorController.text
                : null,
            items: sectorOptions,
            onChanged: (value) {
              viewModel.sectorController.text = value ?? '';
            },
            isRequired: true,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Address",
            hintText: "Enter your complete address",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Address is required';
              }
              return null;
            },
            maxLength: 200,
            controller: viewModel.addressController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Phone Number",
            hintText: "Enter your phone number",
            keyboardType: TextInputType.phone,
            maxLength: 20,
            controller: viewModel.phoneController,
          ),
          const SizedBox(height: 24),
          Text(
            "Emergency Contact Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Person to Notify",
            hintText: "Enter full name",
            maxLength: 100,
            controller: viewModel.personToNotifyController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Contact Number",
            hintText: "Enter contact number",
            keyboardType: TextInputType.phone,
            maxLength: 20,
            controller: viewModel.ptnContactController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: "Relationship",
            hintText: "Enter relationship (e.g. Spouse, Child)",
            maxLength: 50,
            controller: viewModel.ptnRelationshipController,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Back",
                    onTap: viewModel.previousStep,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ButtonWidget(
                    type: ButtonType.primary.type,
                    btnText: "Submit Registration",
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        viewModel.nextStep();
                        viewModel.signUp(context);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rest of your form fields...
          // ... [keep all other existing fields]
        ],
      ),
    );
  }

  Widget _buildDropdownAutocomplete({
    required String label,
    required String hintText,
    required List<String> options,
    required TextEditingController controller,
    required String? Function(String?) validator,
    double maxHeight = 200.0,
    double maxWidth = 400.0, // Add this parameter to control width
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return options.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            if (controller.text != fieldTextEditingController.text) {
              fieldTextEditingController.text = controller.text;
            }

            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              validator: validator,
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: maxWidth, // Set the width constraint here
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                      maxWidth: maxWidth, // Also constrain the width here
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
          },
        ),
      ],
    );
  }

  Widget _buildVerificationPendingScreen(
      BuildContext context, SignUpProvider viewModel) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay (same as sign up screen)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loginBG2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: ResponsiveBuilder(
                builder: (context, sizingInfo) {
                  final isMobile = sizingInfo.isMobile;
                  final maxWidth = isMobile ? double.infinity : 500.0;

                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    padding: isMobile
                        ? EdgeInsets.zero // Mobile: No padding
                        : EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    child: Center(
                      child: CommonCard(
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: isMobile ? 20 : 40,
                        ),
                        borderRadius: isMobile ? 0 : 12.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 80,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Registration Submitted!",
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Your farmer account is pending verification by DA personnel.",
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 40,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Verification Process:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 16 : 18,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "1. Your registration details have been submitted\n"
                                    "2. DA personnel will review your information\n"
                                    "3. You'll receive an SMS/email once approved\n"
                                    "4. This process typically takes 1-2 business days",
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Reference Number:",
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "#DA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: isMobile ? double.infinity : 300,
                              child: ButtonWidget(
                                type: ButtonType.primary.type,
                                btnText: "Back to Login",
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/signIn');
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement contact support
                              },
                              child: Text(
                                "Need help? Contact DA Support",
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            }
          : null,
      isExpanded: true,
    );
  }

  @override
  SignUpProvider viewModelBuilder(BuildContext context) {
    return SignUpProvider(context);
  }
}
