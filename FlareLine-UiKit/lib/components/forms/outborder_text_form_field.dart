// ignore_for_file: prefer_const_constructors

library flareline_uikit;

import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flutter/material.dart';

class OutBorderTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final int? maxLines;
  final TextEditingController? controller;
  final bool? enabled;
  final bool showErrorText;
  final Color errorBorderColor;
  final Widget? suffixWidget;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final Widget? icon;
  final FormFieldValidator? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final TextStyle? textStyle;
  final int? maxLength;
  final TextStyle? hintStyle;
  final Color? focusColor;
  final TextStyle? errorTextStyle;

  const OutBorderTextFormField({
    super.key,
    this.labelText,
    this.initialValue,
    this.hintText,
    this.hintStyle,
    this.showErrorText = true,
    this.errorBorderColor = Colors.redAccent,
    this.maxLines = 1,
    this.enabled,
    this.controller,
    this.suffixWidget,
    this.obscureText,
    this.keyboardType,
    this.icon,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.textStyle,
    this.focusColor,
    this.errorTextStyle,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText ?? '',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.maxFinite,
          height: maxLines == 1 ? 50 : null,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: TextFormField(
                  keyboardType: keyboardType,
                  obscureText: obscureText ?? false,
                  enabled: enabled,
                  initialValue: initialValue,
                  controller: controller,
                  maxLines: maxLines,
                  validator: validator,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                  style: textStyle,
                  decoration: InputDecoration(
                    prefixIcon: icon,
                    prefixIconConstraints: const BoxConstraints(
                      maxWidth: 35,
                      maxHeight: 35,
                    ),
                    border: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: FlarelineColors.border, width: 1),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: FlarelineColors.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (focusColor ?? FlarelineColors.primary),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    hintText: hintText,
                    hintStyle: hintStyle,
                    // This is the key fix:
                    errorStyle: showErrorText
                        ? errorTextStyle ??
                            TextStyle(
                              color: errorBorderColor,
                              fontSize: 9,
                            )
                        : TextStyle(height: 0, fontSize: 0),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: errorBorderColor),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: errorBorderColor),
                    ),
                  ),
                ),
              ),
              if (suffixWidget != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: suffixWidget,
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
