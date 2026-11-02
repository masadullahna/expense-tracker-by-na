import 'package:flutter/material.dart';

/// App-wide color constants.
class AppColors {
  AppColors._();

  /// Income / money in.
  static const Color income = Color(0xFF16A34A);

  /// Expense / money out.
  static const Color expense = Color(0xFFDC2626);

  /// Brand accent (matches deepPurple seed).
  static const Color balance = Colors.deepPurple;

  /// Distinct colors for chart segments (category → fixed color).
  static const List<Color> chartPalette = [
    Color(0xFF7C4DFF), // purple
    Color(0xFF448AFF), // blue
    Color(0xFF1DE9B6), // teal
    Color(0xFFFFAB40), // orange
    Color(0xFFFF5252), // red
    Color(0xFFFF4081), // pink
    Color(0xFF536DFE), // indigo
    Color(0xFFFFD740), // amber
    Color(0xFF69F0AE), // green
    Color(0xFFE040FB), // magenta
  ];
}
