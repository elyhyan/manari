import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../studio_colors.dart';
import '../studio_spacing.dart';

/// A 20px-radius pill tag. Accent = rust border/text/wash fill,
/// neutral = ink-14%-opacity border + secondary text.
class StudioTag extends StatelessWidget {
  const StudioTag(this.label, {super.key, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(StudioRadius.pill + 8),
        color: accent ? StudioColors.rust50Wash : Colors.transparent,
        border: Border.all(
          color: accent ? StudioColors.rust.withValues(alpha: 0.3) : StudioColors.lineDefault,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          color: accent ? StudioColors.rust : StudioColors.textSecondary,
        ),
      ),
    );
  }
}

/// A tag with a leading solid dot + mono uppercase label, e.g. "In use".
class StudioStatusPill extends StatelessWidget {
  const StudioStatusPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(StudioRadius.pill + 8),
        border: Border.all(color: StudioColors.rust.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: StudioColors.rust, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              letterSpacing: 1.0,
              color: StudioColors.rust,
            ),
          ),
        ],
      ),
    );
  }
}
