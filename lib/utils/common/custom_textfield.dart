import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.validator,
    required this.focusNode,
    required this.hint,
    this.obscureText,
    this.onFieldSubmitted,
    this.autofillHints,
    this.keyboardType = TextInputType.emailAddress,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode focusNode;
  final String hint;
  final bool? obscureText;
  final Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      controller: controller,
      style: AppTheme.textFieldBodyTheme(context),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            width: 4, // Adjusted border width
            color: AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            width: 2,
            color: AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            style: BorderStyle.solid,
            width: 2,
            color: Colors.red, // Error color
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            style: BorderStyle.solid,
            width: 2,
            color: Colors.red, // Error color on focus
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: hint,
      ),
      autofillHints: autofillHints,
      obscureText: obscureText ?? false,
      validator: validator,
    );
  }
}
