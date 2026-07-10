import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A soft multi-stop radial mesh, used on hero moments and key accent
/// surfaces only — never for body backgrounds. Always pair with dark ink
/// text, never light text (except [StudioMeshVariant.ink]).
///
/// Adapted from the web reference's stacked `radial-gradient(...)` layers +
/// an SVG `feTurbulence` grain filter. Flutter has no gradient-stacking or
/// turbulence filter primitive, so both are approximated here: the blobs are
/// painted as separate radial shaders on one canvas, and the grain is a
/// fixed-seed scatter of translucent dots rather than true fractal noise.
enum StudioMeshVariant { signature, rust, ink, sand }

class _Blob {
  const _Blob(this.center, this.radius, this.color);
  final Alignment center;
  final double radius; // fraction of the shorter side
  final Color color;
}

const _signatureBlobs = [
  _Blob(Alignment(-0.84, -0.82), 0.62, Color(0xB8C38F94)),
  _Blob(Alignment(0.72, -0.88), 0.66, Color(0xCCDBE0A0)),
  _Blob(Alignment(-0.26, -0.12), 0.74, Color(0xA6B6D1BE)),
  _Blob(Alignment(-0.80, 0.64), 0.64, Color(0xB8A5BFA5)),
  _Blob(Alignment(-0.06, 0.56), 0.66, Color(0xADD4C2AE)),
  _Blob(Alignment(0.82, 0.76), 0.64, Color(0xA6B8D4DB)),
];

const _rustBlobs = [
  _Blob(Alignment(-0.76, -0.80), 0.66, Color(0xCCE4703A)),
  _Blob(Alignment(0.68, -0.84), 0.68, Color(0xD6DEA84A)),
  _Blob(Alignment(-0.16, 0.0), 0.74, Color(0xA3D47A48)),
  _Blob(Alignment(-0.84, 0.60), 0.66, Color(0xC7A43218)),
  _Blob(Alignment(0.72, 0.68), 0.66, Color(0xB3EAC68E)),
];

const _inkBlobs = [
  _Blob(Alignment(-0.64, -0.64), 0.72, Color(0xE63A3026)),
  _Blob(Alignment(0.60, -0.76), 0.68, Color(0xF3262019)),
  _Blob(Alignment(-0.10, 0.04), 0.78, Color(0xCC322A22)),
  _Blob(Alignment(-0.84, 0.68), 0.66, Color(0xF51C1812)),
  _Blob(Alignment(0.76, 0.72), 0.64, Color(0x80BC4B2C)),
];

const _sandBlobs = [
  _Blob(Alignment(-0.80, -0.76), 0.62, Color(0xC2D2C6AC)),
  _Blob(Alignment(0.72, -0.84), 0.68, Color(0xD6EBE4C4)),
  _Blob(Alignment(-0.24, 0.08), 0.76, Color(0xA3DCD2B8)),
  _Blob(Alignment(-0.80, 0.64), 0.66, Color(0xC2C3B69E)),
  _Blob(Alignment(0.76, 0.72), 0.64, Color(0xB3E4DAC0)),
];

const Map<StudioMeshVariant, List<_Blob>> _meshBlobs = {
  StudioMeshVariant.signature: _signatureBlobs,
  StudioMeshVariant.rust: _rustBlobs,
  StudioMeshVariant.ink: _inkBlobs,
  StudioMeshVariant.sand: _sandBlobs,
};

const Map<StudioMeshVariant, Color> _meshBase = {
  StudioMeshVariant.signature: Color(0xFFDCE7DC),
  StudioMeshVariant.rust: Color(0xFFF6ECDF),
  StudioMeshVariant.ink: Color(0xFF0E0C0A),
  StudioMeshVariant.sand: Color(0xFFECE6D8),
};

class StudioMeshGradient extends StatelessWidget {
  const StudioMeshGradient({
    super.key,
    this.variant = StudioMeshVariant.signature,
    this.borderRadius = BorderRadius.zero,
    this.grainOpacity = 0.22,
    this.child,
  });

  final StudioMeshVariant variant;
  final BorderRadius borderRadius;
  final double grainOpacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: _MeshPainter(variant: variant, grainOpacity: grainOpacity),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({required this.variant, required this.grainOpacity});

  final StudioMeshVariant variant;
  final double grainOpacity;

  static final Map<StudioMeshVariant, List<Offset>> _grainCache = {};

  List<Offset> _grainDots(Size size) {
    final key = variant;
    final cached = _grainCache[key];
    if (cached != null) return cached;
    final random = Random(variant.index * 7919 + 13);
    final count = 2200;
    final dots = List<Offset>.generate(
      count,
      (_) => Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
    );
    _grainCache[key] = dots;
    return dots;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()..color = _meshBase[variant]!;
    canvas.drawRect(rect, base);

    final shortSide = min(size.width, size.height);
    for (final blob in _meshBlobs[variant]!) {
      final center = blob.center.alongSize(size);
      final radius = blob.radius * shortSide;
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [blob.color, blob.color.withAlpha(0)],
          const [0.0, 1.0],
        );
      canvas.drawRect(rect, paint);
    }

    final isDark = variant == StudioMeshVariant.ink;
    final grainPaint = Paint()
      ..color = (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
          .withValues(alpha: grainOpacity * 0.5)
      ..strokeWidth = 1
      ..blendMode = isDark ? BlendMode.plus : BlendMode.multiply;
    canvas.drawPoints(ui.PointMode.points, _grainDots(size), grainPaint);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) =>
      oldDelegate.variant != variant || oldDelegate.grainOpacity != grainOpacity;
}
