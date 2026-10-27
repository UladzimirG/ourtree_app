import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';

/// Тёплый крафтовый фон с натуральной бумажной фактурой.
///
/// Вместо регулярной сетки используются мягкие разводы, волокна и мелкие
/// вкрапления. Они детерминированы, поэтому не «мерцают» при перерисовке.
class KraftBackground extends StatelessWidget {
  const KraftBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Только базовый тон и фактура: без широких градиентных «плашек».
        const Positioned.fill(
          child: ColoredBox(color: AppColors.background),
        ),
        const Positioned.fill(
          child: CustomPaint(painter: _KraftTexturePainter()),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _KraftTexturePainter extends CustomPainter {
  const _KraftTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final area = size.width * size.height;
    final random = Random(19470613);

    _paintWashes(canvas, size, random, area);
    _paintFibres(canvas, size, random, area);
    _paintPulpClumps(canvas, size, random, area);
    _paintFlecks(canvas, size, random, area);
  }

  /// Неправильные мягкие пятна вместо ровного градиента.
  ///
  /// Они локальные и почти незаметные: создают ощущение неравномерной
  /// пропитки листа, но не образуют полосу или «плашку» в шапке.
  void _paintWashes(
    Canvas canvas,
    Size size,
    Random random,
    double area,
  ) {
    final count = (area / 120000).clamp(5, 16).round();
    for (var i = 0; i < count; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final baseRadius = 70 + random.nextDouble() * 170;
      final vertices = 9 + random.nextInt(6);
      final path = Path();
      for (var point = 0; point < vertices; point++) {
        final angle = point / vertices * pi * 2;
        final radius = baseRadius * (0.55 + random.nextDouble() * 0.8);
        final position =
            center + Offset(cos(angle) * radius, sin(angle) * radius * 0.72);
        if (point == 0) {
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }
      path.close();

      final paint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34)
        ..color = random.nextBool()
            ? const Color(0x084B3018)
            : const Color(0x0AFFF0D2);
      canvas.drawPath(path, paint);
    }
  }

  /// Волокна в основном идут вдоль листа, как в настоящем крафте.
  ///
  /// Часть волокон рисуется пучками по 2–4 шт., поэтому фактура выглядит
  /// неравномерной, а не как равномерный шум.
  void _paintFibres(
    Canvas canvas,
    Size size,
    Random random,
    double area,
  ) {
    final count = (area / 3000).clamp(120, 700).round();
    for (var i = 0; i < count; i++) {
      final angle = _fibreAngle(random);
      final length = 18 + random.nextDouble() * 96;
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final strands = random.nextDouble() > 0.82 ? 2 + random.nextInt(3) : 1;
      final normal = Offset(-sin(angle), cos(angle));

      for (var strand = 0; strand < strands; strand++) {
        final offset = normal * ((strand - (strands - 1) / 2) * 1.6);
        _drawFibre(
          canvas,
          start + offset,
          angle + (random.nextDouble() - 0.5) * 0.09,
          length * (0.82 + random.nextDouble() * 0.32),
          2 + random.nextDouble() * 7,
          0.35 + random.nextDouble() * 0.45,
          random.nextBool() ? const Color(0x09462C17) : const Color(0x0AFFF4DC),
        );
      }
    }

    // Короткая «пушистость» — отдельные волоски, торчащие из бумаги.
    final shortCount = (area / 2600).clamp(120, 620).round();
    for (var i = 0; i < shortCount; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      _drawFibre(
        canvas,
        start,
        _fibreAngle(random),
        2 + random.nextDouble() * 11,
        (random.nextDouble() - 0.5) * 2,
        0.3 + random.nextDouble() * 0.35,
        random.nextBool() ? const Color(0x0C3C2512) : const Color(0x0BFFF8E9),
      );
    }
  }

  /// Обычно волокна почти горизонтальные; изредка встречаются поперечные.
  double _fibreAngle(Random random) {
    final roll = random.nextDouble();
    if (roll < 0.7) {
      return (random.nextDouble() - 0.5) * 0.42;
    }
    if (roll < 0.9) {
      return (random.nextDouble() - 0.5) * 1.2;
    }
    return random.nextDouble() * pi * 2;
  }

  void _drawFibre(
    Canvas canvas,
    Offset start,
    double angle,
    double length,
    double bend,
    double width,
    Color color,
  ) {
    final end = start + Offset(cos(angle) * length, sin(angle) * length);
    final normal = Offset(-sin(angle), cos(angle));
    final first = Offset.lerp(start, end, 0.34)! + normal * bend;
    final second = Offset.lerp(start, end, 0.68)! - normal * bend * 0.7;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..color = color;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        first.dx,
        first.dy,
        second.dx,
        second.dy,
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, paint);
  }

  /// Небольшие сгустки волокон — там бумажная масса плотнее.
  void _paintPulpClumps(
    Canvas canvas,
    Size size,
    Random random,
    double area,
  ) {
    final clumps = (area / 130000).clamp(4, 14).round();
    for (var clump = 0; clump < clumps; clump++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final spread = 16 + random.nextDouble() * 46;
      final count = 10 + random.nextInt(22);
      for (var i = 0; i < count; i++) {
        final angle = random.nextDouble() * pi * 2;
        final distance = pow(random.nextDouble(), 1.9) * spread;
        _drawFibre(
          canvas,
          center + Offset(cos(angle) * distance, sin(angle) * distance),
          _fibreAngle(random),
          2 + random.nextDouble() * 9,
          (random.nextDouble() - 0.5) * 1.6,
          0.3 + random.nextDouble() * 0.3,
          random.nextBool() ? const Color(0x0D3B2512) : const Color(0x0CFFF8E8),
        );
      }
    }
  }

  /// Крошка собирается в небольшие группы, как в настоящей бумаге.
  void _paintFlecks(
    Canvas canvas,
    Size size,
    Random random,
    double area,
  ) {
    final clusters = (area / 110000).clamp(4, 16).round();
    final dark = Paint()..color = const Color(0x1A3B2614);
    final light = Paint()..color = const Color(0x16FFF7E7);

    for (var cluster = 0; cluster < clusters; cluster++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final spread = 14 + random.nextDouble() * 72;
      final count = 8 + random.nextInt(26);
      for (var i = 0; i < count; i++) {
        final angle = random.nextDouble() * pi * 2;
        final distance = pow(random.nextDouble(), 1.8) * spread;
        canvas.drawCircle(
          center + Offset(cos(angle) * distance, sin(angle) * distance),
          0.3 + random.nextDouble() * 1.05,
          random.nextDouble() > 0.45 ? dark : light,
        );
      }
    }

    // Совсем редкие одиночные вкрапления по всему листу.
    final sparse = (area / 9500).clamp(60, 240).round();
    for (var i = 0; i < sparse; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.25 + random.nextDouble() * 0.7,
        random.nextDouble() > 0.5 ? dark : light,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
