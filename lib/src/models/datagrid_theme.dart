import 'package:flutter/material.dart';

/// A simple theme that derives all grid colors from a few seed colors.
///
/// Instead of setting 80+ color properties manually, just provide
/// [primaryColor], [backgroundColor], [foregroundColor], and [borderColor].
/// All other colors are automatically derived.
///
/// Use the predefined themes or create your own:
/// ```dart
/// // Use a preset
/// OmDataGridTheme.light()
/// OmDataGridTheme.dark()
///
/// // Custom theme with just a primary color
/// OmDataGridTheme(primaryColor: Colors.indigo)
///
/// // Full control over base colors
/// OmDataGridTheme(
///   primaryColor: Color(0xFF1E293B),
///   backgroundColor: Colors.white,
///   foregroundColor: Color(0xFF1E293B),
///   borderColor: Color(0xFFE2E8F0),
/// )
/// ```
class OmDataGridTheme {
  /// The primary accent color used for selections, active states, buttons.
  final Color primaryColor;

  /// The main background color for the grid and surfaces.
  final Color backgroundColor;

  /// The main text/icon color.
  final Color foregroundColor;

  /// The color used for borders and dividers.
  final Color borderColor;

  /// The color used on top of [primaryColor] (e.g., text on primary buttons).
  final Color onPrimaryColor;

  /// The color used for error/destructive actions.
  final Color errorColor;

  /// Creates a custom theme from seed colors.
  ///
  /// Only [primaryColor] is truly required — the rest have smart defaults
  /// for a light theme.
  const OmDataGridTheme({
    this.primaryColor = const Color(0xFF1E293B),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.foregroundColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0xFFE2E8F0),
    this.onPrimaryColor = const Color(0xFFFFFFFF),
    this.errorColor = const Color(0xFFF44242),
  });

  // ---------------------------------------------------------------------------
  // Predefined themes
  // ---------------------------------------------------------------------------

  /// A clean light theme (default). White background, dark text.
  factory OmDataGridTheme.light({Color? primaryColor}) {
    final primary = primaryColor ?? const Color(0xFF1E293B);
    return OmDataGridTheme(
      primaryColor: primary,
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFF1E293B),
      borderColor: const Color(0xFFE2E8F0),
      onPrimaryColor: const Color(0xFFFFFFFF),
    );
  }

  /// A dark theme. Dark background, light text.
  factory OmDataGridTheme.dark({Color? primaryColor}) {
    final primary = primaryColor ?? const Color(0xFF60A5FA);
    return OmDataGridTheme(
      primaryColor: primary,
      backgroundColor: const Color(0xFF1E1E2E),
      foregroundColor: const Color(0xFFE2E8F0),
      borderColor: const Color(0xFF334155),
      onPrimaryColor: const Color(0xFF1E1E2E),
      errorColor: const Color(0xFFEF4444),
    );
  }

  /// A blue-accented theme.
  factory OmDataGridTheme.blue() {
    return const OmDataGridTheme(
      primaryColor: Color(0xFF2563EB),
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1E293B),
      borderColor: Color(0xFFDBE5F1),
      onPrimaryColor: Color(0xFFFFFFFF),
    );
  }

  /// A green-accented theme.
  factory OmDataGridTheme.green() {
    return const OmDataGridTheme(
      primaryColor: Color(0xFF16A34A),
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1E293B),
      borderColor: Color(0xFFD1E7DD),
      onPrimaryColor: Color(0xFFFFFFFF),
    );
  }

  /// A purple-accented theme.
  factory OmDataGridTheme.purple() {
    return const OmDataGridTheme(
      primaryColor: Color(0xFF7C3AED),
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1E293B),
      borderColor: Color(0xFFE2D9F3),
      onPrimaryColor: Color(0xFFFFFFFF),
    );
  }

  /// A rose/pink-accented theme.
  factory OmDataGridTheme.rose() {
    return const OmDataGridTheme(
      primaryColor: Color(0xFFE11D48),
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1E293B),
      borderColor: Color(0xFFFCE4EC),
      onPrimaryColor: Color(0xFFFFFFFF),
    );
  }

  // ---------------------------------------------------------------------------
  // Derived colors — used internally by OmDataGridConfiguration.fromTheme()
  // ---------------------------------------------------------------------------

  /// Slightly tinted background (e.g., header background).
  Color get surfaceColor {
    // Blend background toward foreground by ~2%
    return Color.lerp(backgroundColor, foregroundColor, 0.02)!;
  }

  /// A muted version of foreground for secondary text.
  Color get secondaryTextColor {
    return Color.lerp(foregroundColor, backgroundColor, 0.45)!;
  }

  /// Icon color — slightly muted foreground.
  Color get iconColor {
    return Color.lerp(foregroundColor, backgroundColor, 0.15)!;
  }

  /// Muted icon color.
  Color get mutedIconColor {
    return Color.lerp(foregroundColor, backgroundColor, 0.55)!;
  }

  /// Hover color — very light foreground tint.
  Color get hoverColor {
    return foregroundColor.withAlpha(20);
  }

  /// Selection color — light foreground tint.
  Color get selectionColor {
    return primaryColor.withAlpha(40);
  }

  /// Input fill color — slightly different from background for contrast.
  Color get inputFillColor {
    return Color.lerp(backgroundColor, foregroundColor, _isDark ? 0.12 : 0.06)!;
  }

  /// Input border — same as border.
  Color get inputBorderColor => borderColor;

  /// Input focus border — same as primary.
  Color get inputFocusBorderColor => primaryColor;

  /// Unselected pagination background.
  Color get paginationUnselectedBackground {
    return Color.lerp(backgroundColor, borderColor, 0.15)!;
  }

  /// Unselected pagination foreground.
  Color get paginationUnselectedForeground {
    return Color.lerp(foregroundColor, backgroundColor, 0.35)!;
  }

  /// Drag feedback shadow color.
  Color get shadowColor {
    return foregroundColor.withAlpha(26);
  }

  /// Chart/overlay surface colors — depends on theme brightness.
  Color get overlaySurfaceColor => backgroundColor;

  /// Chart title/icon on dark overlays.
  Color get overlayOnSurfaceColor {
    return _isDark ? onPrimaryColor : const Color(0xFFFFFFFF);
  }

  /// Whether this is a dark theme.
  bool get _isDark {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
        Brightness.dark;
  }
}
