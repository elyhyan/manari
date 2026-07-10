import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../studio_colors.dart';
import '../studio_shadows.dart';

/// A pill-shaped nav container: white bg, 1px border, 30px radius, subtle
/// shadow. Active item gets a rust-wash pill background.
class StudioPillNav extends StatelessWidget {
  const StudioPillNav({
    super.key,
    required this.logo,
    required this.items,
    required this.activeIndex,
    required this.onSelect,
  });

  final String logo;
  final List<String> items;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: StudioColors.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: StudioColors.lineDefault),
        boxShadow: StudioShadows.raised,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              logo,
              style: GoogleFonts.archivoBlack(fontSize: 14, color: StudioColors.rust, letterSpacing: -0.3),
            ),
          ),
          Container(width: 1, height: 15, color: StudioColors.lineDefault),
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: i == activeIndex ? StudioColors.rust50Wash : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    color: i == activeIndex ? StudioColors.textPrimary : StudioColors.textSecondary,
                    fontWeight: i == activeIndex ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
