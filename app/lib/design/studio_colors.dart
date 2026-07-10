import 'package:flutter/widgets.dart';

/// Color tokens for the Studio design system.
///
/// Ported from the "Harry Kwok · Studio System v1.0" design reference.
/// Values are pulled directly from that source — do not invent new ones.
abstract final class StudioColors {
  // Core surfaces
  static const sand = Color(0xFFEAE6DD); // page base
  static const paper = Color(0xFFF4F1EA); // raised sections
  static const card = Color(0xFFFFFFFF); // surfaces
  static const ink = Color(0xFF1C1A17); // primary text / dark ground
  static const rust = Color(0xFFBC4B2C); // accent / action

  // Text on paper
  static const textPrimary = Color(0xFF1C1A17);
  static const textSecondary = Color(0xFF4A463E);
  static const textTertiary = Color(0xFF6B675E);
  static const textMuted = Color(0xFF9A9489);

  // Accent ramp
  static const rust700Hover = Color(0xFFA23D22);
  static const rust600Base = Color(0xFFBC4B2C);
  static const rust200Line = Color(0xFFE5C9BC);
  static const rust50Wash = Color(0xFFF6EBE6);

  // Borders / lines (ink at various opacities)
  static const lineSubtle = Color(0x1A1C1A17); // ~10%
  static const lineDefault = Color(0x1F1C1A17); // ~12%
  static const lineStrong = Color(0x381C1A17); // ~22%

  // Signature mesh gradient tones
  static const meshRose = Color(0xFFC38F94);
  static const meshChartreuse = Color(0xFFDBE0A0);
  static const meshSage = Color(0xFFB6D1BE);
  static const meshIce = Color(0xFFB8D4DB);

  // Rust mesh variant
  static const meshRust1 = Color(0xFFE4703A);
  static const meshAmber = Color(0xFFDEA84A);
  static const meshCrimson = Color(0xFFA43218);

  // Sand mesh variant
  static const meshDune = Color(0xFFD2C6AC);
  static const meshLinen = Color(0xFFEBE4C4);
  static const meshEarth = Color(0xFFC3B69E);
}
