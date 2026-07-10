import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../studio_colors.dart';

/// An ink-background block with a mono uppercase rust eyebrow and a large
/// display headline in paper color. Used for section breaks and emphasis.
///
/// Adapted from the reference's "pull quote" — generalized to a callout
/// since this app has no case-study copy to quote.
class StudioInkCallout extends StatelessWidget {
  const StudioInkCallout({super.key, required this.eyebrow, required this.text, this.caption});

  final String eyebrow;
  final String text;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(color: StudioColors.ink, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(fontSize: 10, letterSpacing: 1.8, color: StudioColors.rust),
          ),
          const SizedBox(height: 18),
          Text(
            text,
            style: GoogleFonts.archivoBlack(
              fontSize: 23,
              height: 1.12,
              letterSpacing: -0.4,
              color: StudioColors.paper,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 16),
            Text(
              caption!,
              style: const TextStyle(fontSize: 12.5, color: StudioColors.textMuted, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}
