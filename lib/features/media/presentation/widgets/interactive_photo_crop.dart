import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Интерактивное кадрирование: фото двигается пальцем/мышью, масштаб —
/// жестом «щипок» или кнопками. Результат — точка фокуса и масштаб.
class InteractivePhotoCrop extends StatefulWidget {
  const InteractivePhotoCrop({
    super.key,
    required this.source,
    required this.position,
    required this.zoom,
    required this.onChanged,
    this.aspectRatio = 16 / 9,
  });

  final String source;
  final PhotoPosition position;
  final double zoom;
  final void Function(PhotoPosition position, double zoom) onChanged;
  final double aspectRatio;

  @override
  State<InteractivePhotoCrop> createState() => _InteractivePhotoCropState();
}

class _InteractivePhotoCropState extends State<InteractivePhotoCrop> {
  late PhotoPosition _position;
  late double _zoom;
  double _startZoom = 1.4;
  bool _gestureActive = false;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _zoom = widget.zoom.clamp(1.0, 3.0);
  }

  @override
  void didUpdateWidget(covariant InteractivePhotoCrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_gestureActive) return;
    if (oldWidget.position != widget.position ||
        oldWidget.zoom != widget.zoom ||
        oldWidget.source != widget.source) {
      _position = widget.position;
      _zoom = widget.zoom.clamp(1.0, 3.0);
    }
  }

  void _commit() {
    widget.onChanged(_position, _zoom);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureActive = true;
    _startZoom = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final box = context.size;
    if (box == null || box.width <= 0 || box.height <= 0) return;

    final zoom = (_startZoom * details.scale).clamp(1.0, 3.0);
    final overflowX = box.width * (zoom - 1);
    final overflowY = box.height * (zoom - 1);

    var x = _position.x;
    var y = _position.y;
    if (overflowX > 1) {
      x += details.focalPointDelta.dx / overflowX * 100 * -1;
    }
    if (overflowY > 1) {
      y += details.focalPointDelta.dy / overflowY * 100 * -1;
    }

    setState(() {
      _zoom = zoom;
      _position = PhotoPosition(
        x: x.clamp(0, 100),
        y: y.clamp(0, 100),
      );
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _gestureActive = false;
    _commit();
  }

  void _changeZoom(double delta) {
    setState(() {
      _zoom = (_zoom + delta).clamp(1.0, 3.0);
    });
    _commit();
  }

  void _reset() {
    setState(() {
      _position = PhotoPosition.center;
      _zoom = 1.4;
    });
    _commit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              onDoubleTap: _reset,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF1C1712)),
                  Transform.scale(
                    scale: _zoom,
                    alignment: photoAlignment(_position),
                    child: FamilyPhoto(
                      source: widget.source,
                      fit: BoxFit.cover,
                      alignment: photoAlignment(_position),
                      fallback: const ColoredBox(
                        color: AppColors.kraftWash,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(painter: const _GridPainter()),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xAA000000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_zoom.toStringAsFixed(1)}×',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.mediaCropHint,
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: l10n.mediaZoomOut,
              visualDensity: VisualDensity.compact,
              onPressed: () => _changeZoom(-0.1),
              icon: const Icon(Icons.zoom_out),
            ),
            IconButton(
              tooltip: l10n.mediaZoomIn,
              visualDensity: VisualDensity.compact,
              onPressed: () => _changeZoom(0.1),
              icon: const Icon(Icons.zoom_in),
            ),
            IconButton(
              tooltip: l10n.mediaCropReset,
              visualDensity: VisualDensity.compact,
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = size.width * i / 3;
      final dy = size.height * i / 3;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
