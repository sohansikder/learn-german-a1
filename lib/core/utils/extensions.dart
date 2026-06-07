import 'package:flutter/material.dart';

/// Useful extension methods for common Dart/Flutter types.

extension StringExtensions on String {
  /// Capitalize the first letter of a string.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Convert to title case.
  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
}

extension ContextExtensions on BuildContext {
  /// Quick access to the current theme.
  ThemeData get theme => Theme.of(this);

  /// Quick access to the text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to the color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Whether the current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension NumExtensions on num {
  /// Create a vertical SizedBox spacer.
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Create a horizontal SizedBox spacer.
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
