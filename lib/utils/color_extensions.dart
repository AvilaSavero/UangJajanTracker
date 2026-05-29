import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color withOpacitySafe(double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    return withAlpha((opacity * 255).round());
  }
}
