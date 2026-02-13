import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final String? Function(String?) validator;
  final bool obscureText;
  const CustomTextFormField(
      {super.key,
      required this.theme,
      required this.hintText,
      required this.validator,
      this.obscureText = false});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        obscureText: obscureText,
        autocorrect: false,
        textDirection: TextDirection.rtl, // RTL support for Arabic
        keyboardType: TextInputType.emailAddress, // Appropriate keyboard
        decoration: InputDecoration(
          errorMaxLines: 1,
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.grey[400], // Better hint color
          ),
          hintTextDirection: TextDirection.rtl, // RTL hint alignment
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) => validator(value));
  }
}
