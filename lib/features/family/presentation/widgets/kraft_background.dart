import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';

/// «Крафтовый» фон оригинального приложения: тёплый коричневый с фактурой.
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.65, -0.8),
                radius: 1.1,
                colors: <Color>[Color(0x38FFF4DC), Color(0x00FFF4DC)],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.85, 0.9),
                radius: 1.0,
                colors: <Color>[Color(0x2E5A3418), Color(0x005A3418)],
              ),
            ),
          ),
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
    final horizontal = Paint()
      ..color = const Color(0x095A3A1C)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontal);
    }

    final vertical = Paint()
      ..color = const Color(0x0DFFF4DC)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vertical);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
