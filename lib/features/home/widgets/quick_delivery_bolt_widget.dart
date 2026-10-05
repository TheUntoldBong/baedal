import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class QuickDeliveryBoltWidget extends StatefulWidget {
  final double size;
  const QuickDeliveryBoltWidget({super.key, this.size = 26});

  @override
  State<QuickDeliveryBoltWidget> createState() => _QuickDeliveryBoltWidgetState();
}

class _QuickDeliveryBoltWidgetState extends State<QuickDeliveryBoltWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 5400),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion == _reduceMotion && (reduceMotion || _controller.isAnimating)) {
      return;
    }
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size * _QuickBoltPainter.aspect, widget.size),
        painter: _QuickBoltPainter(animation: _controller),
      ),
    );
  }
}

class _QuickBoltPainter extends CustomPainter {
  final Animation<double> animation;

  _QuickBoltPainter({required this.animation}) : super(repaint: animation);

  static const double aspect = 0.95;

  static const List<Offset> _boltPoints = [
    Offset(0.60, 0.00), Offset(0.10, 0.56), Offset(0.40, 0.56),
    Offset(0.34, 1.00), Offset(0.90, 0.42), Offset(0.58, 0.42),
  ];

  static const Rect _backBox = Rect.fromLTWH(0.00, 0.04, 0.70, 0.92);
  static const Rect _frontBox = Rect.fromLTWH(0.30, 0.04, 0.70, 0.92);

  static const List<Color> _palette = [
    Color(0xFF3B5BFF),
    Color(0xFF29A9F0),
  ];

  static const double _frontLag = 0.5;

  static const double _hold = 0.55;

  static const double _feather = 0.22;

  Size? _cachedSize;
  _BoltGeometry? _cachedGeometry;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    if (_cachedSize != size || _cachedGeometry == null) {
      _cachedSize = size;
      _cachedGeometry = _BoltGeometry.build(size);
    }
    final _BoltGeometry geometry = _cachedGeometry!;
    final double t = animation.value;

    final _ColorStep back = _stepAt(t);
    final _ColorStep front = _stepAt(t + _frontLag);

    canvas.saveLayer(Offset.zero & size, Paint());
    _drawBolt(canvas, geometry.back, geometry.backBounds, back, geometry.tipRounding);

    canvas.drawPath(geometry.front, Paint()..blendMode = BlendMode.clear);
    canvas.drawPath(geometry.front, Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.frontGap * 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round);
    canvas.restore();
    
    final double bloom = math.sin(front.wipe * math.pi);
    if (bloom > 0.01) {
      canvas.drawPath(geometry.front, Paint()
        ..color = front.to.withValues(alpha: 0.22 * bloom)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, geometry.glowRadius * bloom));
    }

    _drawBolt(canvas, geometry.front, geometry.frontBounds, front, geometry.tipRounding);
  }

  void _drawBolt(Canvas canvas, Path path, Rect bounds, _ColorStep step, double rounding) {
    final Paint fill = Paint();
    if (step.wipe <= 0) {
      fill.color = step.from;
    } else if (step.wipe >= 1) {
      fill.color = step.to;
    } else {
      fill.shader = _wipeShader(bounds, step);
    }

    canvas.drawPath(path, fill);
    canvas.drawPath(path, Paint()
      ..color = fill.color
      ..shader = fill.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = rounding
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round);
  }

  Shader _wipeShader(Rect bounds, _ColorStep step) {
    final double edge = step.wipe * (1 + _feather * 2) - _feather;
    final double crest = edge.clamp(0.0, 1.0);
    final double leading = (edge + _feather).clamp(0.0, 1.0);
    final double trailing = (edge - _feather).clamp(0.0, 1.0);
    return LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [step.to, step.to, step.crest, step.from, step.from],
      stops: [0, trailing, crest, leading, 1],
    ).createShader(bounds);
  }

  _ColorStep _stepAt(double phase) {
    final double scaled = (phase % 1.0) * _palette.length;
    final int index = scaled.floor();
    final double within = scaled - index;
    return _ColorStep(
      from: _palette[index % _palette.length],
      to: _palette[(index + 1) % _palette.length],
      wipe: within <= _hold ? 0 : Curves.easeInOutCubic.transform((within - _hold) / (1 - _hold)),
    );
  }

  @override
  bool shouldRepaint(_QuickBoltPainter oldDelegate) => oldDelegate.animation != animation;
}

class _ColorStep {
  final Color from;
  final Color to;
  final double wipe;

  const _ColorStep({required this.from, required this.to, required this.wipe});

  Color get crest => Color.lerp(to, Colors.white, 0.30)!;
}

class _BoltGeometry {
  final Path back;
  final Path front;
  final Rect backBounds;
  final Rect frontBounds;
  final double tipRounding;
  final double frontGap;
  final double glowRadius;

  const _BoltGeometry({
    required this.back, required this.front,
    required this.backBounds, required this.frontBounds,
    required this.tipRounding, required this.frontGap, required this.glowRadius,
  });

  static _BoltGeometry build(Size size) {
    final Path unitBolt = Path()..addPolygon(_QuickBoltPainter._boltPoints, true);
    final Path back = unitBolt.transform(_matrixFor(_QuickBoltPainter._backBox, size));
    final Path front = unitBolt.transform(_matrixFor(_QuickBoltPainter._frontBox, size));
    return _BoltGeometry(
      back: back,
      front: front,
      backBounds: back.getBounds(),
      frontBounds: front.getBounds(),
      tipRounding: size.height * 0.045,
      frontGap: size.height * 0.05,
      glowRadius: size.height * 0.12,
    );
  }

  static Float64List _matrixFor(Rect box, Size size) {
    return (Matrix4.diagonal3Values(size.width, size.height, 1)
      ..translateByDouble(box.left, box.top, 0, 1)
      ..scaleByDouble(box.width, box.height, 1, 1))
        .storage;
  }
}