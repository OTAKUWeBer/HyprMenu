import 'package:flutter/material.dart';

/// Provides a scale factor relative to a 1080p baseline.
/// On a 1080p screen, scale = 1.0.
/// On a 768p laptop, scale ≈ 0.71.
/// On a 1440p monitor, scale ≈ 1.33.
class Responsive {
  /// The baseline window height we designed for (window on a 1080p screen).
  static const double _baselineHeight = 970.0;

  /// Minimum scale to avoid unusably tiny UI.
  static const double _minScale = 0.6;

  /// Maximum scale to avoid oversized UI.
  static const double _maxScale = 1.5;

  /// Returns a scale factor based on the current window/screen height.
  static double scale(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final raw = screenHeight / _baselineHeight;
    return raw.clamp(_minScale, _maxScale);
  }

  /// Convenience: scale a pixel value.
  static double sp(BuildContext context, double value) {
    return value * scale(context);
  }
}
