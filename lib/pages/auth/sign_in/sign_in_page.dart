import 'package:flareline/pages/auth/sign_in/sign_in_provider.dart';
import 'package:flareline_uikit/core/mvvm/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SignInWidget extends BaseWidget<SignInProvider> {
  @override
  Widget bodyWidget(
      BuildContext context, SignInProvider viewModel, Widget? child) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loginBG2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Color overlay/filter
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          // Your content
          Center(
            child: SingleChildScrollView(
              child: ResponsiveBuilder(
                builder: (context, sizingInfo) {
                  final maxWidth =
                      sizingInfo.isMobile ? double.infinity : 440.0;
                  return Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    margin: EdgeInsets.all(10),
                    child: CommonCard(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: sizingInfo.isMobile ? 20 : 20,
                      ),
                      borderRadius: 8.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 80,
                            child: Image.asset('assets/DA_image.jpg'),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "AgriTrack",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _signInFormWidget(context, viewModel),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Loading indicator overlay
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  SignInProvider viewModelBuilder(BuildContext context) {
    return SignInProvider(context);
  }

  Widget _signInFormWidget(BuildContext context, SignInProvider viewModel) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutBorderTextFormField(
            labelText: "Username",
            hintText: "Enter your Username",
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username is required';
              }
              return null;
            },
            suffixWidget: SvgPicture.asset(
              'assets/signin/email.svg',
              width: 22,
              height: 22,
            ),
            controller: viewModel.emailController,
            showErrorText: false,
            errorBorderColor: Colors.red,
          ),

          const SizedBox(height: 16),
          OutBorderTextFormField(
            obscureText: true,
            labelText: AppLocalizations.of(context)!.password,
            hintText: "Enter your Password",
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            suffixWidget: SvgPicture.asset(
              'assets/signin/lock.svg',
              width: 22,
              height: 22,
            ),
            controller: viewModel.passwordController,
            onFieldSubmitted: (value) {
              if (_formKey.currentState!.validate()) {
                viewModel.signIn(context);
              }
            },
            showErrorText: false,
            errorBorderColor: Colors.red,
          ),

          const SizedBox(height: 8),
          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/forgotPwd');
                // Add forgot password functionality
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: GlobalColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Email/Password Sign In Button
          SizedBox(
            width: double.infinity,
            child: ButtonWidget(
              type: ButtonType.primary.type,
              btnText: AppLocalizations.of(context)!.signIn,
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  viewModel.signIn(context);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                  child: Divider(
                height: 1,
                color: GlobalColors.border,
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  AppLocalizations.of(context)!.or,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Expanded(
                  child: Divider(
                height: 1,
                color: GlobalColors.border,
              )),
            ],
          ),
          const SizedBox(height: 20),
          // Google Sign In Button
          SizedBox(
            width: double.infinity,
            child: ButtonWidget(
              color: Colors.white,
              borderColor: GlobalColors.border,
              iconWidget: SvgPicture.asset(
                'assets/brand/brand-01.svg',
                width: 25,
                height: 25,
              ),
              btnText: AppLocalizations.of(context)!.signInWithGoogle,
              textColor: Colors.black87,
              onTap: () {
                viewModel.signInWithGoogle(context);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Sign up prompt
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  // Add navigation to sign up
                  Navigator.of(context).pushNamed('/signUp');
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: GlobalColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
