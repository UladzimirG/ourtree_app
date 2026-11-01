import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';

/// Светлый крафтовый фон с неравномерной бумажной фактурой.
///
/// Рисунок детерминирован (фиксированные seed), поэтому не «мерцает» при
/// перерисовке. Плотность фактуры задаётся низкочастотным полем: на листе
/// появляются более «плотные» и почти чистые участки, как у настоящей бумаги.
/// Раньше шум был равномерным, и фон выглядел однородной заливкой.
class KraftBackground extends StatelessWidget {
  const KraftBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
    final density = _DensityField(seed: 1947);

    _paintClouds(canvas, size, random, area);
    _paintFibres(canvas, size, random, density, area);
    _paintPulpClumps(canvas, size, random, density, area);
    _paintFlecks(canvas, size, random, density, area);
    _paintVignette(canvas, size);
  }

  /// Крупные мягкие разводы трёх тонов: тёплый, глубокий и светлый.
  ///
  /// Они дают «пропитку» листа и убирают ощущение ровной заливки, но
  /// остаются локальными — плашек и полос в шапке не появляется.
  void _paintClouds(Canvas canvas, Size size, Random random, double area) {
    final count = (area / 260000).clamp(2, 7).round();

    void layer(Color color, double minAlpha, double maxAlpha, double blur) {
      for (var i = 0; i < count; i++) {
        final center = Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        );
        final width = 140 + random.nextDouble() * 320;
        final height = 90 + random.nextDouble() * 240;
        final paint = Paint()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
          ..color = color.withValues(
            alpha: minAlpha + random.nextDouble() * (maxAlpha - minAlpha),
          );

        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate((random.nextDouble() - 0.5) * 0.9);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          paint,
        );
        canvas.restore();
      }
    }

    layer(AppColors.backgroundWarm, 0.05, 0.10, 70);
    layer(AppColors.backgroundCloud, 0.04, 0.08, 60);
    layer(AppColors.backgroundDeep, 0.03, 0.06, 90);
  }

  /// Волокна идут в основном вдоль листа, как в настоящем крафте.
  ///
  /// Часть волокон рисуется пучками, а плотность зависит от поля: где-то
  /// волокон много, где-то лист почти чистый — именно это и даёт
  /// «неоднородность» вместо равномерного шума.
  void _paintFibres(
    Canvas canvas,
    Size size,
    Random random,
    _DensityField density,
    double area,
  ) {
    final count = (area / 2600).clamp(180, 900).round();
    for (var i = 0; i < count; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final d = density.at(start.dx / size.width, start.dy / size.height);
      if (random.nextDouble() > 0.25 + d * 0.95) continue;

      final length = 14 + pow(random.nextDouble(), 1.6) * 150;
      final dark = random.nextDouble() > 0.42;
      final base = dark ? const Color(0xFF3B2512) : const Color(0xFFFFF8E8);
      final alpha = (dark ? 0.05 : 0.06) + d * 0.05;

      _drawFibre(
        canvas,
        start,
        _fibreAngle(random),
        length.toDouble(),
        (random.nextDouble() - 0.5) * 3,
        0.4 + random.nextDouble() * 0.5,
        base.withValues(alpha: alpha),
      );

      // Пучок: рядом ещё 1–3 волокна, как расщеплённый волосок бумаги.
      if (random.nextDouble() > 0.8) {
        final strands = 1 + random.nextInt(3);
        for (var s = 0; s < strands; s++) {
          final offset = Offset(
            start.dx + (random.nextDouble() - 0.5) * 10,
            start.dy + (random.nextDouble() - 0.5) * 10,
          );
          _drawFibre(
            canvas,
            offset,
            _fibreAngle(random),
            length * (0.35 + random.nextDouble() * 0.5),
            (random.nextDouble() - 0.5) * 2,
            0.3 + random.nextDouble() * 0.3,
            base.withValues(alpha: alpha * 0.8),
          );
        }
      }
    }
  }

  double _fibreAngle(Random random) {
    // Волокна вдоль листа, но с заметным разбросом — иначе фактура «гребёнкой».
    if (random.nextDouble() > 0.82) return random.nextDouble() * pi * 2;
    return (random.nextDouble() - 0.5) * 0.7;
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
    _DensityField density,
    double area,
  ) {
    final clumps = (area / 120000).clamp(4, 16).round();
    for (var clump = 0; clump < clumps; clump++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final d = density.at(center.dx / size.width, center.dy / size.height);
      if (d < 0.42) continue;

      final spread = 14 + random.nextDouble() * 52;
      final count = 8 + random.nextInt(24);
      for (var i = 0; i < count; i++) {
        final angle = random.nextDouble() * pi * 2;
        final distance = pow(random.nextDouble(), 1.9) * spread;
        _drawFibre(
          canvas,
          center + Offset(cos(angle) * distance, sin(angle) * distance),
          _fibreAngle(random),
          2 + random.nextDouble() * 10,
          (random.nextDouble() - 0.5) * 1.6,
          0.3 + random.nextDouble() * 0.3,
          random.nextBool()
              ? const Color(0xFF3B2512).withValues(alpha: 0.05 + d * 0.03)
              : const Color(0xFFFFF8E8).withValues(alpha: 0.05 + d * 0.03),
        );
      }
    }
  }

  /// Крошка собирается в небольшие группы, как в настоящей бумаге.
  void _paintFlecks(
    Canvas canvas,
    Size size,
    Random random,
    _DensityField density,
    double area,
  ) {
    final clusters = (area / 100000).clamp(4, 18).round();
    final dark = Paint()..color = const Color(0xFF3B2614).withValues(alpha: 0.09);
    final light =
        Paint()..color = const Color(0xFFFFF7E7).withValues(alpha: 0.08);

    for (var cluster = 0; cluster < clusters; cluster++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final d = density.at(center.dx / size.width, center.dy / size.height);
      if (random.nextDouble() > 0.35 + d * 0.9) continue;

      final spread = 12 + random.nextDouble() * 78;
      final count = 8 + random.nextInt(28);
      for (var i = 0; i < count; i++) {
        final angle = random.nextDouble() * pi * 2;
        final distance = pow(random.nextDouble(), 1.8) * spread;
        canvas.drawCircle(
          center + Offset(cos(angle) * distance, sin(angle) * distance),
          0.3 + random.nextDouble() * 1.1,
          random.nextDouble() > 0.45 ? dark : light,
        );
      }
    }

    // Совсем редкие одиночные вкрапления по всему листу.
    final sparse = (area / 9000).clamp(50, 220).round();
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

  /// Едва заметное затемнение к краям: лист выглядит объёмнее.
  void _paintVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: <Color>[
          const Color(0x00000000),
          const Color(0xFF3B2512).withValues(alpha: 0.045),
        ],
        stops: const <double>[0.55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Низкочастотное поле плотности (value noise) с плавной интерполяцией.
///
/// Значения берутся из сетки случайных чисел и сглаживаются — так получаются
/// крупные «плотные» и «чистые» зоны вместо равномерного шума.
class _DensityField {
  _DensityField({required int seed}) : _grid = _buildGrid(seed);

  static const int _cells = 6;

  final List<double> _grid;

  static List<double> _buildGrid(int seed) {
    final random = Random(seed);
    return List<double>.generate(
      (_cells + 1) * (_cells + 1),
      (_) => random.nextDouble(),
    );
  }

  /// Плотность в точке `(x, y)` в долях листа (0…1).
  double at(double x, double y) {
    final gx = x.clamp(0.0, 1.0) * _cells;
    final gy = y.clamp(0.0, 1.0) * _cells;
    final x0 = gx.floor().clamp(0, _cells - 1);
    final y0 = gy.floor().clamp(0, _cells - 1);
    final tx = _smooth(gx - x0);
    final ty = _smooth(gy - y0);

    double v(int ix, int iy) => _grid[iy * (_cells + 1) + ix];

    final top = _lerp(v(x0, y0), v(x0 + 1, y0), tx);
    final bottom = _lerp(v(x0, y0 + 1), v(x0 + 1, y0 + 1), tx);
    return _lerp(top, bottom, ty);
  }

  static double _smooth(double t) => t * t * (3 - 2 * t);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}