import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../studio_colors.dart';

/// A single row: mono index number in rust + title + meta line, with a
/// trailing status pill or arrow. Rows are meant to be stacked inside a
/// card and divided by 1px hairlines (see [StudioListCard]).
///
/// Adapted from the reference's "case study row" — generalized here since
/// this app lists notes/reminders, not case studies.
class StudioListRow extends StatelessWidget {
  const StudioListRow({
    super.key,
    required this.index,
    required this.title,
    required this.meta,
    this.trailing,
    this.onTap,
  });

  final String index;
  final String title;
  final String meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(index, style: GoogleFonts.ibmPlexMono(fontSize: 11, color: StudioColors.rust)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(meta, style: const TextStyle(fontSize: 12.5, color: StudioColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// White card wrapper that stacks [StudioListRow]s with 1px hairline dividers.
class StudioListCard extends StatelessWidget {
  const StudioListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudioColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudioColors.lineDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: StudioColors.lineSubtle),
            children[i],
          ],
        ],
      ),
    );
  }
}
