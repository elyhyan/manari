import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'studio_colors.dart';

/// Type scale for the Studio design system.
///
/// Three families, clear roles:
/// - Display (Archivo Black): headlines only, never body text.
/// - Body (Hanken Grotesk): body copy, sub-heads, all interface text.
/// - Mono (IBM Plex Mono): labels, metadata, numbers — always uppercase + tracked.
abstract final class StudioType {
  static TextStyle _display({required double fontSize, required double height}) =>
      GoogleFonts.archivoBlack(
        fontSize: fontSize,
        height: height,
        letterSpacing: fontSize * -0.03,
        color: StudioColors.textPrimary,
      );

  static TextStyle _body({
    required double fontSize,
    required double height,
    FontWeight weight = FontWeight.w400,
    Color color = StudioColors.textPrimary,
  }) =>
      GoogleFonts.hankenGrotesk(
        fontSize: fontSize,
        height: height,
        fontWeight: weight,
        color: color,
      );

  /// Uppercase + tracked mono label. Apply `.toUpperCase()` to the string yourself.
  static TextStyle _label({
    required double fontSize,
    Color color = StudioColors.textPrimary,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        letterSpacing: fontSize * 0.16,
        fontWeight: weight,
        color: color,
      );

  static TextStyle display = _display(fontSize: 68, height: 0.96);
  static TextStyle h1 = _display(fontSize: 40, height: 1.0);
  static TextStyle h2 = _display(fontSize: 28, height: 1.0);
  static TextStyle h3 = _body(fontSize: 20, height: 1.2, weight: FontWeight.w600);
  static TextStyle bodyLarge = _body(fontSize: 18, height: 1.65);
  static TextStyle body = _body(fontSize: 15.5, height: 1.72, color: StudioColors.textSecondary);
  static TextStyle small = _body(fontSize: 13, height: 1.6, color: StudioColors.textTertiary);
  static TextStyle label = _label(fontSize: 11, color: StudioColors.textMuted);
}
