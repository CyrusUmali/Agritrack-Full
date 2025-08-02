import 'package:flareline/pages/auth/sign_up/sign_up_provider.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:provider/provider.dart';

class SignUpForms {
  // Move formKey to a higher level (could also move to provider)
  static final _formKey = GlobalKey<FormState>();

  static Widget buildFormContent(
      BuildContext context, SignUpProvider viewModel, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
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
            controller: viewModel.emailController,
          ),
        ],
      ),
    );
  }
}

class _SignUpContent extends StatelessWidget {
  const _SignUpContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Stack(
            children: [
              // Background
              if (!isMobile) ...[
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/loginBG2.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.2)),
              ] else ...[
                Container(color: Colors.white),
              ],

              // Main content
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 800.0,
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    padding: isMobile
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: CommonCard(
                        padding: EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: isMobile ? 16.0 : 40.0,
                        ),
                        borderRadius: isMobile ? 0 : 12.0,
                        child: SignUpForms.buildFormContent(
                            context, viewModel, isMobile),
                      ),
                    ),
                  ),
                ),
              ),

              // Loading indicator - now using Selector to only rebuild when isLoading changes
              Selector<SignUpProvider, bool>(
                selector: (_, vm) => vm.isLoading,
                builder: (context, isLoading, child) {
                  return isLoading
                      ? Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
