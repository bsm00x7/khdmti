import 'package:flutter/material.dart';

class ServiceTextField extends StatelessWidget {
  const ServiceTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14,
        color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: TextDirection.rtl,
        hintStyle: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 13,
          color: isDark ? const Color(0xff475569) : const Color(0xffA0AEC0),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xff1E293B) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(isDark),
        enabledBorder: _border(isDark),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff1173D4), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEF4444), width: 1.8),
        ),
        errorStyle: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
      ),
    );
  }

  OutlineInputBorder _border(bool isDark) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      );
}
