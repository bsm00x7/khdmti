// ============================================================
// responsive_helper.dart
// Flutter Adaptive & Responsive Design Utility
// Based on: https://docs.flutter.dev/ui/adaptive-responsive
//
// Covers: Android · iOS · Web
// Usage:  Import this single file into any screen/widget.
// ============================================================

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Screen-size categories used throughout the app.
enum ScreenSize {
  /// < 600 dp  →  phones (portrait / landscape)
  mobile,

  /// 600–839 dp  →  tablets (portrait) / large phones (landscape)
  tablet,

  /// 840–1199 dp  →  tablets (landscape) / small desktops
  desktop,

  /// ≥ 1200 dp  →  wide desktops / TVs / large web viewports
  wide,
}

class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 840;
  static const double desktop = 1200;
}

// ─────────────────────────────────────────────────────────────
// 2.  RESPONSIVE HELPER  (pure utility — no Widget)
//     Resolves values based on current MediaQuery width.
// ─────────────────────────────────────────────────────────────

class ResponsiveHelper {
  ResponsiveHelper._();

  // ── Screen-size detection ──────────────────────────────────

  static ScreenSize screenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.mobile) return ScreenSize.mobile;
    if (width < Breakpoints.tablet) return ScreenSize.tablet;
    if (width < Breakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.wide;
  }

  static bool isMobile(BuildContext context) =>
      screenSize(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      screenSize(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      screenSize(context) == ScreenSize.desktop;

  static bool isWide(BuildContext context) =>
      screenSize(context) == ScreenSize.wide;

  /// True when layout should show a side-nav / multi-pane layout.
  static bool isLargeScreen(BuildContext context) {
    final s = screenSize(context);
    return s == ScreenSize.desktop || s == ScreenSize.wide;
  }

  // ── Platform detection ────────────────────────────────────

  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobileDevice => isAndroid || isIOS;

  // ── Orientation ───────────────────────────────────────────

  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  // ── Adaptive value selector ───────────────────────────────

  /// Returns [mobile], [tablet], [desktop] or [wide] depending
  /// on the current screen size.  Narrower values fall back to
  /// the widest provided value that is smaller than current size.
  ///
  /// Example:
  /// ```dart
  /// double padding = ResponsiveHelper.value(
  ///   context,
  ///   mobile: 16,
  ///   tablet: 24,
  ///   desktop: 40,
  /// );
  /// ```
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final size = screenSize(context);
    switch (size) {
      case ScreenSize.wide:
        return wide ?? desktop ?? tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  // ── Column count helper ────────────────────────────────────

  /// Sensible default grid column counts per screen size.
  static int columnCount(BuildContext context) => value(
        context,
        mobile: 1,
        tablet: 2,
        desktop: 3,
        wide: 4,
      );

  // ── Adaptive padding ──────────────────────────────────────

  /// Horizontal page padding that grows with screen width.
  static EdgeInsets pagePadding(BuildContext context) {
    final horizontal = value<double>(
      context,
      mobile: 16,
      tablet: 24,
      desktop: 40,
      wide: 64,
    );
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  /// Constrained content width for wide screens
  /// (keeps lines readable and mirrors web best-practice).
  static double maxContentWidth(BuildContext context) => value(
        context,
        mobile: double.infinity,
        tablet: 720,
        desktop: 960,
        wide: 1200,
      );

  // ── Adaptive font size ────────────────────────────────────

  /// Scale a base font size relative to current screen size.
  static double fontSize(BuildContext context, double base) {
    final factor = value<double>(
      context,
      mobile: 1.0,
      tablet: 1.05,
      desktop: 1.1,
      wide: 1.15,
    );
    return base * factor;
  }
}

// ─────────────────────────────────────────────────────────────
// 3.  RESPONSIVE BUILDER WIDGET
//     LayoutBuilder-based: rebuilds on every resize.
//     Prefer this over MediaQuery.of(context) in sub-trees
//     that must not be affected by text-scale or safe-area.
// ─────────────────────────────────────────────────────────────

/// Builds different UI trees based on available layout width.
///
/// ```dart
/// ResponsiveBuilder(
///   mobile:  (ctx, constraints) => MobileLayout(),
///   tablet:  (ctx, constraints) => TabletLayout(),
///   desktop: (ctx, constraints) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
  });

  final Widget Function(BuildContext, BoxConstraints) mobile;
  final Widget Function(BuildContext, BoxConstraints)? tablet;
  final Widget Function(BuildContext, BoxConstraints)? desktop;
  final Widget Function(BuildContext, BoxConstraints)? wide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;

        if (width >= Breakpoints.desktop && wide != null) {
          return wide!(ctx, constraints);
        }
        if (width >= Breakpoints.tablet && desktop != null) {
          return desktop!(ctx, constraints);
        }
        if (width >= Breakpoints.mobile && tablet != null) {
          return tablet!(ctx, constraints);
        }
        return mobile(ctx, constraints);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 4.  ADAPTIVE LAYOUT WIDGET
//     Combines navigation pattern + body for large-screen UX.
//     On mobile → bottom navigation bar.
//     On desktop → permanent NavigationRail or Drawer.
// ─────────────────────────────────────────────────────────────

/// Wraps a Scaffold with adaptive navigation.
///
/// ```dart
/// AdaptiveLayout(
///   selectedIndex: _tab,
///   onDestinationSelected: (i) => setState(() => _tab = i),
///   destinations: [
///     NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
///     NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
///   ],
///   body: pages[_tab],
/// )
/// ```
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.appBar,
  });

  final Widget body;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final large = ResponsiveHelper.isLargeScreen(context);

    if (large) {
      // ── Desktop / Tablet landscape: side navigation rail ──
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // ── Mobile / Tablet portrait: bottom navigation bar ───
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 5.  SAFE AREA + CONSTRAINED CONTENT BOX
//     Wraps body in SafeArea and centers content at max width.
//     Essential for web and large screens.
// ─────────────────────────────────────────────────────────────

/// Centers page content at [ResponsiveHelper.maxContentWidth]
/// and applies safe-area insets.
///
/// Drop this around your page body instead of plain Padding:
/// ```dart
/// ConstrainedPage(child: MyPageContent())
/// ```
class ConstrainedPage extends StatelessWidget {
  const ConstrainedPage({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.maxContentWidth(context);
    final effectivePadding = padding ?? ResponsiveHelper.pagePadding(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 6.  RESPONSIVE GRID
//     Automatically switches column count by screen size.
// ─────────────────────────────────────────────────────────────

/// A responsive grid that adapts columns to screen width.
///
/// ```dart
/// ResponsiveGrid(
///   children: items.map((item) => ItemCard(item)).toList(),
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileCols,
    this.tabletCols,
    this.desktopCols,
    this.wideCols,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileCols;
  final int? tabletCols;
  final int? desktopCols;
  final int? wideCols;

  @override
  Widget build(BuildContext context) {
    final cols = ResponsiveHelper.value<int>(
      context,
      mobile: mobileCols ?? 1,
      tablet: tabletCols ?? 2,
      desktop: desktopCols ?? 3,
      wide: wideCols ?? 4,
    );

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map(
                (child) => SizedBox(width: itemWidth, child: child),
              )
              .toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 7.  BuildContext EXTENSIONS
//     Syntactic sugar — use anywhere after importing this file.
// ─────────────────────────────────────────────────────────────

extension ResponsiveContext on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // Screen-size helpers
  ScreenSize get screenSize => ResponsiveHelper.screenSize(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isWide => ResponsiveHelper.isWide(this);
  bool get isLargeScreen => ResponsiveHelper.isLargeScreen(this);

  // Orientation
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);

  // Platform
  bool get isWeb => ResponsiveHelper.isWeb;
  bool get isAndroid => ResponsiveHelper.isAndroid;
  bool get isIOS => ResponsiveHelper.isIOS;

  // Adaptive utilities
  int get columnCount => ResponsiveHelper.columnCount(this);
  EdgeInsets get pagePadding => ResponsiveHelper.pagePadding(this);
  double get maxContentWidth => ResponsiveHelper.maxContentWidth(this);

  /// Select a value based on screen size.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) =>
      ResponsiveHelper.value(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        wide: wide,
      );

  /// Scale [base] font size for current screen size.
  double adaptiveFontSize(double base) => ResponsiveHelper.fontSize(this, base);
}
