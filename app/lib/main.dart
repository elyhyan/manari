import 'package:flutter/material.dart';

import 'design/studio_style_guide_screen.dart';
import 'design/studio_theme.dart';

void main() {
  runApp(const ManariApp());
}

class ManariApp extends StatelessWidget {
  const ManariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manari',
      theme: StudioTheme.light(),
      // Temporary home while the design system is being verified — real
      // navigation (Notes/Reminders/Views) lands in roadmap Phase 4.
      home: const StudioStyleGuideScreen(),
    );
  }
}
