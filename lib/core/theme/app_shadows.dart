import 'package:flutter/material.dart';

/// Light Minimal elevation (§5): a single hairline-soft card shadow is the
/// maximum elevation for persistent UI, plus a slightly deeper shadow for
/// transient overlays (sheets, menus). Glow/featured shadows are retired —
/// `featured`/`focusGlow` remain only so pre-redesign widgets compile and are
/// removed in UI-11.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A111113), // rgba(17,17,19,.04)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x1F111113), // rgba(17,17,19,.12)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Retired (UI-11) — kept so legacy widgets compile.
  static const List<BoxShadow> featured = card;
  static const List<BoxShadow> focusGlow = <BoxShadow>[];
}
