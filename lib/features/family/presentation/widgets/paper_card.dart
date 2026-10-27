import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';

/// Карточка-«бумажка» с наклоном, тенью и полоской скотча сверху.
///
/// Повторяет `.paper-card` и `.tape` из `src/index.css`.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.onTap,
    this.tilt = 0,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 18),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Наклон в градусах, как `--tilt` в оригинальном CSS.
  final double tilt;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);

    return Transform.rotate(
      angle: tilt * math.pi / 180,
      child: Padding(
        padding: margin,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[AppColors.sticker, AppColors.paper],
                ),
                borderRadius: borderRadius,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                  BoxShadow(
                    color: AppColors.whiteWash,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: borderRadius,
                    splashColor: AppColors.activeWash,
                    highlightColor: AppColors.activeWash,
                    child: Padding(padding: padding, child: child),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Transform.rotate(
                    angle: -2 * math.pi / 180,
                    child: Container(
                      width: 58,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.tape,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: AppColors.whiteWash),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
