import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design.dart';

/// A living style guide mirroring the "Studio System v1.0" reference doc's
/// sections (Colour, Typography, Space & Form, Components), rendered as
/// real Flutter widgets rather than static HTML. This is a temporary home
/// screen for design verification — real navigation lands in roadmap Phase 4.
class StudioStyleGuideScreen extends StatelessWidget {
  const StudioStyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          children: [
            _cover(),
            const SizedBox(height: 56),
            _sectionHeader('01', 'Colour', 'Warm neutrals, one disciplined accent.'),
            _colourSection(),
            const SizedBox(height: 64),
            _sectionHeader('02', 'Typography', 'Three faces, clear roles.'),
            _typographySection(),
            const SizedBox(height: 64),
            _sectionHeader('03', 'Space & form', '4px base grid, soft geometric radii.'),
            _spaceSection(),
            const SizedBox(height: 64),
            _sectionHeader('04', 'Components', 'The working parts, adapted for Flutter.'),
            _componentsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _cover() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANARI · STUDIO SYSTEM · V1.0',
          style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 2.0, color: StudioColors.textMuted),
        ),
        const SizedBox(height: 22),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'The\nStudio\nSystem'),
              TextSpan(text: '.', style: TextStyle(color: StudioColors.rust)),
            ],
          ),
          style: StudioType.display.copyWith(fontSize: 52),
        ),
        const SizedBox(height: 18),
        const Text(
          'Design tokens translated from the portfolio reference into a real Flutter theme — colour, type, spacing and the core components, ready to build the app on.',
          style: TextStyle(fontSize: 16, height: 1.6, color: StudioColors.textSecondary),
        ),
        const SizedBox(height: 32),
        const Divider(height: 1, color: StudioColors.lineDefault),
      ],
    );
  }

  Widget _sectionHeader(String index, String title, String caption) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        children: [
          Text(index, style: GoogleFonts.ibmPlexMono(fontSize: 12, color: StudioColors.rust)),
          Text(title, style: StudioType.h2.copyWith(fontSize: 26)),
          Text(caption, style: const TextStyle(fontSize: 13.5, color: StudioColors.textMuted)),
        ],
      ),
    );
  }

  Widget _colourSection() {
    final core = [
      ('Sand', StudioColors.sand, '#EAE6DD', 'Page base'),
      ('Paper', StudioColors.paper, '#F4F1EA', 'Raised sections'),
      ('Card', StudioColors.card, '#FFFFFF', 'Surfaces'),
      ('Ink', StudioColors.ink, '#1C1A17', 'Primary text'),
      ('Rust', StudioColors.rust, '#BC4B2C', 'Accent / action'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Core'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (name, color, hex, sub) in core)
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: StudioColors.lineDefault),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(hex, style: GoogleFonts.ibmPlexMono(fontSize: 10, color: StudioColors.textMuted)),
                    Text(sub, style: const TextStyle(fontSize: 11, color: StudioColors.textMuted)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        _label('Signature gradient'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final v in StudioMeshVariant.values)
              SizedBox(
                width: 160,
                height: 110,
                child: StudioMeshGradient(
                  variant: v,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        v.name,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 9.5,
                          letterSpacing: 1.2,
                          color: v == StudioMeshVariant.ink
                              ? Colors.white.withValues(alpha: 0.5)
                              : StudioColors.ink.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _swatchColumn('Text on paper', const [
              ('Ink — primary', StudioColors.textPrimary, '#1C1A17'),
              ('Secondary', StudioColors.textSecondary, '#4A463E'),
              ('Tertiary', StudioColors.textTertiary, '#6B675E'),
              ('Muted / meta', StudioColors.textMuted, '#9A9489'),
            ])),
            const SizedBox(width: 24),
            Expanded(child: _swatchColumn('Accent ramp', const [
              ('Rust 700 — hover', StudioColors.rust700Hover, '#A23D22'),
              ('Rust 600 — base', StudioColors.rust600Base, '#BC4B2C'),
              ('Rust 200 — line', StudioColors.rust200Line, '#E5C9BC'),
              ('Rust 50 — wash', StudioColors.rust50Wash, '#F6EBE6'),
            ])),
          ],
        ),
      ],
    );
  }

  Widget _swatchColumn(String title, List<(String, Color, String)> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              for (final (name, color, hex) in rows)
                Container(
                  color: StudioColors.paper,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: StudioColors.lineDefault))),
                        const SizedBox(width: 10),
                        Text(name, style: const TextStyle(fontSize: 13)),
                      ]),
                      Text(hex, style: GoogleFonts.ibmPlexMono(fontSize: 10.5, color: StudioColors.textMuted)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typographySection() {
    final families = [
      ('Archivo Black', 'Display & headlines only. Tight tracking, never for body.', StudioType.display.copyWith(fontSize: 36)),
      ('Hanken Grotesk', 'Body, UI, sub-heads. 300–700 weights.', StudioType.body.copyWith(fontSize: 36, color: StudioColors.textPrimary)),
      ('IBM Plex Mono', 'Labels, metadata, numbers. Uppercase, tracked.', StudioType.label.copyWith(fontSize: 32, color: StudioColors.textPrimary)),
    ];
    final scale = [
      ('Display / 68', StudioType.display.copyWith(fontSize: 40), 'Systems thinker'),
      ('H1 / 40', StudioType.h1.copyWith(fontSize: 32), 'Selected work'),
      ('H2 / 28', StudioType.h2, 'How I work'),
      ('H3 / 20', StudioType.h3, 'A structural gap worth solving'),
      ('Body L / 18', StudioType.bodyLarge, 'Every note and reminder, one unified item.'),
      ('Body / 15.5', StudioType.body, 'Thinking in systems, reasoning through complexity.'),
      ('Small / 13', StudioType.small, 'Captions, helper text, secondary metadata.'),
      ('Label / 11', StudioType.label.copyWith(color: StudioColors.textPrimary), 'DESIGNER · DEVELOPER'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (name, desc, style) in families)
              Container(
                width: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: StudioColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: StudioColors.lineDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Aa', style: style),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: StudioColors.textTertiary, height: 1.4)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _label('Scale'),
        const SizedBox(height: 12),
        for (final (name, style, sample) in scale)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: StudioColors.lineDefault)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 90,
                  child: Text(name, style: GoogleFonts.ibmPlexMono(fontSize: 10, color: StudioColors.textMuted)),
                ),
                Expanded(child: Text(sample, style: style)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _spaceSection() {
    final spacing = [
      (4.0, 'xs'), (8.0, 'sm'), (16.0, 'md'), (24.0, 'lg'),
      (32.0, 'xl'), (48.0, '2xl'), (64.0, '3xl'), (96.0, '4xl'),
    ];
    final radii = [(4.0, 'sm'), (8.0, 'md'), (12.0, 'lg'), (999.0, 'pill')];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Spacing scale'),
        const SizedBox(height: 14),
        for (final (value, name) in spacing)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text('${value.toInt()} · $name', style: GoogleFonts.ibmPlexMono(fontSize: 11, color: StudioColors.textMuted)),
                ),
                Container(height: 14, width: value, decoration: BoxDecoration(color: StudioColors.rust, borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
        const SizedBox(height: 24),
        _label('Radius'),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final (value, name) in radii)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: StudioColors.lineStrong),
                        borderRadius: BorderRadius.circular(value > 40 ? 28 : value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(name, style: GoogleFonts.ibmPlexMono(fontSize: 10, color: StudioColors.textMuted)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _label('Elevation'),
        const SizedBox(height: 14),
        Row(
          children: [
            _elevationSwatch('flat', StudioShadows.flat),
            const SizedBox(width: 18),
            _elevationSwatch('raised', StudioShadows.raised),
            const SizedBox(width: 18),
            _elevationSwatch('float', StudioShadows.float),
          ],
        ),
      ],
    );
  }

  Widget _elevationSwatch(String name, List<BoxShadow> shadow) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 56,
          decoration: BoxDecoration(color: StudioColors.card, borderRadius: BorderRadius.circular(10), boxShadow: shadow),
        ),
        const SizedBox(height: 12),
        Text(name, style: GoogleFonts.ibmPlexMono(fontSize: 10, color: StudioColors.textMuted)),
      ],
    );
  }

  Widget _componentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel('Buttons', Wrap(
          spacing: 14,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StudioButton(label: 'Get in touch →', onPressed: () {}),
            StudioButton(label: 'View work', variant: StudioButtonVariant.outline, onPressed: () {}),
            StudioButton(label: 'Read more →', variant: StudioButtonVariant.text, onPressed: () {}),
            StudioButton(label: 'Download CV', variant: StudioButtonVariant.monoPill, onPressed: () {}),
            SizedBox(width: 160, height: 44, child: StudioGradientButton(label: 'Signature', onPressed: () {})),
          ],
        )),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _panel('Navigation', StudioPillNav(
                logo: 'MN',
                items: const ['Notes', 'Reminders', 'Views'],
                activeIndex: 0,
                onSelect: (_) {},
              )),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _panel('Tags & status', Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  StudioTag('Design Systems', accent: true),
                  StudioTag('Personal'),
                  StudioTag('Offline'),
                  StudioStatusPill('In use'),
                ],
              )),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _panel('Info cards', Wrap(
          spacing: 14,
          runSpacing: 14,
          children: const [
            SizedBox(width: 220, child: StudioInfoCard(index: '01', title: 'One item model', body: 'Notes and reminders are filtered views over one table, not two linked ones.')),
            SizedBox(width: 220, child: StudioInfoCard(index: '02', title: 'Offline-first', body: 'The app always works. Sync is an enhancement, never a dependency.')),
            SizedBox(width: 220, child: StudioInfoCard(index: '03', title: 'Real filter logic', body: 'Saved views are an AND/OR condition tree, not a flat filter list.')),
          ],
        )),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _panel('List row', StudioListCard(children: [
                StudioListRow(index: '01', title: 'Ship Phase 3 data layer', meta: 'Reminder · scheduled today', trailing: const StudioStatusPill('Today')),
                StudioListRow(index: '02', title: 'Reconcile Notion export', meta: 'Note · updated yesterday', trailing: const Icon(Icons.arrow_forward, size: 16, color: StudioColors.rust)),
              ])),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _panel('Ink callout', const StudioInkCallout(
                eyebrow: 'Guiding principle',
                text: 'Offline-first,\nalways.',
                caption: 'Used for section breaks against the ink ground.',
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _panel(String label, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: StudioColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudioColors.lineDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _label(label),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.ibmPlexMono(fontSize: 10, letterSpacing: 1.6, color: StudioColors.textMuted),
    );
  }
}
