import 'dart:math' as math;
import 'package:flutter/material.dart';

class CelebrationParticles extends StatelessWidget {
  final Animation<double> animation;
  final Size size;

  const CelebrationParticles({
    super.key,
    required this.animation,
    this.size = const Size(double.infinity, 320),
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return CustomPaint(
            size: size,
            painter: _ConfettiPainter(progress: animation.value),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotationSpeed;
  final int shapeType; // 0: rect, 1: circle, 2: ribbon
  final double wobbleFrequency;

  _Particle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.shapeType,
    required this.wobbleFrequency,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles = _generateParticles();

  _ConfettiPainter({required this.progress});

  static List<_Particle> _generateParticles() {
    final rand = math.Random(42);
    const colors = [
      Color(0xFF10B981), // Emerald
      Color(0xFF20A7DB), // Primary Brand Cyan
      Color(0xFF0284C7), // Deep Sky Blue
      Color(0xFFEC4899), // Coral Pink
      Color(0xFF8B5CF6), // Royal Purple
      Color(0xFF3B82F6), // Electric Blue
      Color(0xFF06B6D4), // Bright Teal Cyan
    ];

    return List.generate(45, (index) {
      final angle = -math.pi / 2 + (rand.nextDouble() - 0.5) * math.pi * 0.9;
      final speed = 190 + rand.nextDouble() * 260;
      return _Particle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        size: 6 + rand.nextDouble() * 6,
        color: colors[index % colors.length],
        rotationSpeed: (rand.nextDouble() - 0.5) * 14,
        shapeType: rand.nextInt(3),
        wobbleFrequency: 2.5 + rand.nextDouble() * 3.5,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final originX = size.width * 0.5;
    final originY = size.height * 0.32;
    const gravity = 450.0;

    for (final p in _particles) {
      final t = progress;
      final currentX = originX + (p.vx * t) + math.sin(t * p.wobbleFrequency * math.pi) * 22;
      final currentY = originY + (p.vy * t) + (0.5 * gravity * t * t);

      final opacity = (1.0 - (progress > 0.65 ? (progress - 0.65) / 0.35 : 0.0)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotationSpeed * progress);

      if (p.shapeType == 0) {
        // Rounded rectangle
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.8),
          paint,
        );
      } else if (p.shapeType == 1) {
        // Circle
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else {
        // Ribbon streamer
        final rrect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size * 1.9, height: p.size * 0.5),
          const Radius.circular(3),
        );
        canvas.drawRRect(rrect, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
