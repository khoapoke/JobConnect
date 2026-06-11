import 'package:flutter/animation.dart';

/// Light Minimal motion tokens (§9). One harmonized language — everything
/// responds, nothing performs. Easing is the same cubic everywhere.
class AppDurations {
  const AppDurations._();

  /// `cubic-bezier(.25,.8,.35,1)` — the single easing curve for the system.
  static const Curve easing = Cubic(0.25, 0.8, 0.35, 1);

  static const press = Duration(milliseconds: 120); // pressables, scale 0.97
  static const state = Duration(milliseconds: 200); // tab/toggle/chip/theme
  static const stagger = Duration(milliseconds: 30); // list fade-up, first load
  static const route = Duration(milliseconds: 300); // page transitions
  static const launch = Duration(milliseconds: 1400); // launch draw-in cap

  // Legacy aliases (pre-redesign call sites). Retuned to the tokens above.
  static const instant = press;
  static const fast = state;
  static const base = state;
  static const splash = launch;
}
