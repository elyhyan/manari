import 'package:flutter/widgets.dart';

/// Elevation tokens, expressed as [BoxShadow] lists.
abstract final class StudioShadows {
  static const flat = [
    BoxShadow(color: Color(0x0F281A1A), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const raised = [
    BoxShadow(color: Color(0x47282216), offset: Offset(0, 8), blurRadius: 20, spreadRadius: -10),
  ];

  static const float = [
    BoxShadow(color: Color(0x73282216), offset: Offset(0, 26), blurRadius: 50, spreadRadius: -22),
  ];
}
