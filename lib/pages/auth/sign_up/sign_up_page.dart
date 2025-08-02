import 'package:flareline/pages/assoc/assoc_bloc/assocs_bloc.dart';
import 'package:flareline/pages/auth/sign_up/sign_up_provider.dart';
import 'package:flareline/pages/auth/sign_up/sign_up_forms.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/mvvm/base_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SignUpWidget extends BaseWidget<SignUpProvider> {
  @override
  Widget bodyWidget(
      BuildContext context, SignUpProvider viewModel, Widget? child) {
    if (viewModel.isPendingVerification) {
      return _buildVerificationPendingScreen(context, viewModel);
    }

    return Scaffold(
      // Add this to prevent keyboard from dismissing
      resizeToAvoidBottomInset: true,
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

              // Main content - Fixed gesture handling to prevent keyboard dismissal
              Center(
                child: SingleChildScrollView(
                  // Add key to prevent rebuilds
                  key: ValueKey('signup_scroll_${viewModel.currentStep}'),
                  physics: ClampingScrollPhysics(),
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
                          horizontal: isMobile
                              ? 16.0
                              : 40.0, // Reduced padding for mobile
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
                            // Form content from separate file
                            SignUpForms.buildFormContent(
                                context, viewModel, isMobile),
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
      return StepState.disabled;
    }
  }

  Widget _buildVerificationPendingScreen(
      BuildContext context, SignUpProvider viewModel) {
    return Scaffold(
      body: Stack(
        children: [
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
                        ? EdgeInsets.zero
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

  @override
  SignUpProvider viewModelBuilder(BuildContext context) {
    return SignUpProvider(context);
  }
}
