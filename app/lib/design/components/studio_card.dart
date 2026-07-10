import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../studio_colors.dart';

/// A white card with a mono numeral, headline, and supporting body text.
/// Adapted from the reference's "value card" — generic enough to use for
/// onboarding highlights, empty-state tips, or feature callouts.
class StudioInfoCard extends StatelessWidget {
  const StudioInfoCard({
    super.key,
    required this.index,
    required this.title,
    required this.body,
  });

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudioColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudioColors.lineDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            index,
            style: GoogleFonts.ibmPlexMono(fontSize: 10, letterSpacing: 1.2, color: StudioColors.rust),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.hankenGrotesk(fontSize: 17, height: 1.25, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 9),
          Text(
            body,
            style: const TextStyle(fontSize: 12.5, color: StudioColors.textTertiary, height: 1.65),
          ),
        ],
      ),
    );
  }
}
