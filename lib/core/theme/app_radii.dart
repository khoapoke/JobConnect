import 'package:flutter/material.dart';

class AppRadii {
  const AppRadii._();

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radius2xl = 40;

  static const BorderRadius sm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius x2l = BorderRadius.all(Radius.circular(radius2xl));

  // Light Minimal radii (§5). Prefer these in new/restyled UI.
  static const double radiusCard = 18;
  static const double radiusButton = 14;
  static const double radiusSheet = 28;
  static const double radiusPill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius button =
      BorderRadius.all(Radius.circular(radiusButton));
  static const BorderRadius input = button;
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(radiusSheet),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(radiusPill));
}