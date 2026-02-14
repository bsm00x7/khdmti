import 'package:flutter/material.dart';

ThemeData ligthTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xffE2E8F0),
    fontFamily: "IBMPlexSansArabic",
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Color(0xff1173D4)),
          foregroundColor: WidgetStatePropertyAll(Color(0xffFFFFFF)),
          textStyle: WidgetStatePropertyAll(TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ))),
    ),
    textTheme: TextTheme(
        displayMedium: TextStyle(
            color: Color(0xff111827),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            color: Color(0xff334155),
            fontSize: 14,
            fontWeight: FontWeight.w500),
        headlineSmall: TextStyle(
            color: Color(0xff64748B),
            fontSize: 14,
            fontWeight: FontWeight.w300),
        titleLarge: TextStyle(
            color: Color(0xff0F172A), fontWeight: FontWeight.bold, fontSize: 50)

        /// name profile
        ///

        ));
