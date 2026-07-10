import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../studio_colors.dart';
import '../studio_mesh_gradient.dart';
import '../studio_spacing.dart';

/// Which of the four button variants from the Studio system to render.
enum StudioButtonVariant {
  /// Solid rust fill, white text. Primary action.
  solid,

  /// Transparent bg, 1px ink-22% border, ink text. Secondary action.
  outline,

  /// Transparent, rust text, no border. Tertiary "read more" links.
  text,

  /// Ink background, mono uppercase label. Utility action (e.g. "Download").
  monoPill,
}

class StudioButton extends StatelessWidget {
  const StudioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = StudioButtonVariant.solid,
  });

  final String label;
  final VoidCallback? onPressed;
  final StudioButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case StudioButtonVariant.solid:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: StudioColors.rust,
            foregroundColor: StudioColors.card,
            disabledBackgroundColor: StudioColors.rust.withValues(alpha: 0.4),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        );

      case StudioButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: StudioColors.textPrimary,
            side: const BorderSide(color: StudioColors.lineStrong),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        );

      case StudioButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: StudioColors.rust,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        );

      case StudioButtonVariant.monoPill:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: StudioColors.ink,
            foregroundColor: StudioColors.paper,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            textStyle: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(label.toUpperCase()),
        );
    }
  }
}

/// The signature-gradient button treatment for hero contexts. Kept as a
/// distinct widget rather than a [StudioButtonVariant] case since it needs
/// the mesh painter, not a flat color.
class StudioGradientButton extends StatelessWidget {
  const StudioGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = StudioMeshVariant.signature,
    this.pill = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final StudioMeshVariant variant;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final radius = pill ? StudioRadius.pill : StudioRadius.md + 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: StudioMeshGradient(
            variant: variant,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
              child: Text(
                label,
                style: const TextStyle(
                  color: StudioColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
