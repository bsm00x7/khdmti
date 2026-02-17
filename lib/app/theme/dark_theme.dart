import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff0F172A),
  fontFamily: "IBMPlexSansArabic",
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    // ── Primary ──
    primary: Color(0xff3B82F6),
    onPrimary: Color(0xffFFFFFF),
    primaryContainer: Color(0xff1173D4),
    onPrimaryContainer: Color(0xffDBEAFB),
    // ── Secondary ──
    secondary: Color(0xff38BDF8),
    onSecondary: Color(0xff003A5C),
    secondaryContainer: Color(0xff0369A1),
    onSecondaryContainer: Color(0xffE0F5FE),
    // ── Tertiary ──
    tertiary: Color(0xff4ADE80),
    onTertiary: Color(0xff14532D),
    tertiaryContainer: Color(0xff166534),
    onTertiaryContainer: Color(0xffDCFCE7),
    // ── Surface ──
    surface: Color(0xff1E293B),
    onSurface: Color(0xffF1F5F9),
    surfaceContainerHighest: Color(0xff0F172A),
    onSurfaceVariant: Color(0xffCBD5E1),
    // ── Error ──
    error: Color(0xffF87171),
    onError: Color(0xff7F1D1D),
    errorContainer: Color(0xff991B1B),
    onErrorContainer: Color(0xffFEE2E2),
    // ── Outline ──
    outline: Color(0xff334155),
    outlineVariant: Color(0xff1E293B),
    // ── Shadow / Scrim ──
    shadow: Color(0xff000000),
    scrim: Color(0xff000000),
    // ── Inverse ──
    inverseSurface: Color(0xffF1F5F9),
    onInverseSurface: Color(0xff1E293B),
    inversePrimary: Color(0xff1173D4),
  ),

  // ── Card ─────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: const Color(0xff1E293B),
    shadowColor: Colors.black.withValues(alpha: .4),
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),

  // ── ElevatedButton ───────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xff334155);
        }
        return const Color(0xff1173D4);
      }),
      foregroundColor: const WidgetStatePropertyAll(Color(0xffFFFFFF)),
      overlayColor: WidgetStateProperty.all(
          const Color(0xffFFFFFF).withValues(alpha: .08)),
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  ),

  // ── OutlinedButton ───────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(Color(0xff3B82F6)),
      side: const WidgetStatePropertyAll(
        BorderSide(color: Color(0xff3B82F6), width: 1.5),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  ),

  // ── TextButton ───────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(Color(0xff3B82F6)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  ),

  // ── SearchBar ────────────────────────────────────────────────
  searchBarTheme: SearchBarThemeData(
    backgroundColor: WidgetStateProperty.all(const Color(0xff1E293B)),
    shadowColor: WidgetStateProperty.all(Colors.transparent),
    elevation: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.focused) ? 2 : 0,
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(color: Color(0xffF1F5F9), fontSize: 14),
    ),
    hintStyle: const WidgetStatePropertyAll(
      TextStyle(color: Color(0xff64748B), fontSize: 14),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16),
    ),
  ),

  // ── NavigationBar ────────────────────────────────────────────
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xff1E293B),
    indicatorColor: const Color(0xff1173D4).withValues(alpha: .25),
    height: 64,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: Color(0xff3B82F6), size: 24);
      }
      return const IconThemeData(color: Color(0xff64748B), size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: Color(0xff3B82F6),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
      }
      return const TextStyle(color: Color(0xff64748B), fontSize: 12);
    }),
  ),

  // ── AppBar ───────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff1E293B),
    foregroundColor: Color(0xffF1F5F9),
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Color(0xff0F172A),
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xffF1F5F9)),
    titleTextStyle: TextStyle(
      fontFamily: "IBMPlexSansArabic",
      color: Color(0xffF1F5F9),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),

  // ── BottomSheet ──────────────────────────────────────────────
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xff1E293B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    elevation: 8,
  ),

  // ── Chip ─────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xff334155),
    selectedColor: const Color(0xff1173D4).withValues(alpha: .3),
    labelStyle: const TextStyle(
      color: Color(0xffCBD5E1),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    side: const BorderSide(color: Color(0xff334155)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),

  // ── Divider ──────────────────────────────────────────────────
  dividerTheme: const DividerThemeData(
    color: Color(0xff334155),
    thickness: 1,
    space: 1,
  ),

  // ── Icon ─────────────────────────────────────────────────────
  iconTheme: const IconThemeData(
    color: Color(0xffF1F5F9),
    size: 24,
  ),

  // ── Input / TextField ─────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xff1E293B),
    hintStyle: const TextStyle(
      color: Color(0xff64748B),
      fontSize: 14,
    ),
    labelStyle: const TextStyle(
      color: Color(0xff94A3B8),
      fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xff334155), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xff3B82F6), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffF87171), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffF87171), width: 1.5),
    ),
  ),

  // ── ListTile ─────────────────────────────────────────────────
  listTileTheme: const ListTileThemeData(
    tileColor: Color(0xff1E293B),
    iconColor: Color(0xff94A3B8),
    titleTextStyle: TextStyle(
      color: Color(0xffF1F5F9),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    subtitleTextStyle: TextStyle(
      color: Color(0xff94A3B8),
      fontSize: 13,
    ),
  ),

  // ── Switch ───────────────────────────────────────────────────
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xffFFFFFF);
      }
      return const Color(0xff64748B);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff1173D4);
      }
      return const Color(0xff334155);
    }),
  ),

  // ── TextTheme ────────────────────────────────────────────────
  textTheme: const TextTheme(
    // Large titles
    displayLarge: TextStyle(
      color: Color(0xffF8FAFC),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Color(0xffF1F5F9),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: Color(0xffF1F5F9),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    // Headlines
    headlineLarge: TextStyle(
      color: Color(0xffF1F5F9),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Color(0xffE2E8F0),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: Color(0xff94A3B8),
      fontSize: 14,
      fontWeight: FontWeight.w300,
    ),
    // Titles
    titleLarge: TextStyle(
      color: Color(0xffF8FAFC),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      color: Color(0xffCBD5E1),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: Color(0xff94A3B8),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    // Body
    bodyLarge: TextStyle(
      color: Color(0xffE2E8F0),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: Color(0xff94A3B8),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: Color(0xff64748B),
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    // Labels
    labelLarge: TextStyle(
      color: Color(0xffCBD5E1),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      color: Color(0xff94A3B8),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: Color(0xff64748B),
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
  ),
);
