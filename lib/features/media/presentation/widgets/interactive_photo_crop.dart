import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/photo_crop.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Открывает полноэкранный редактор кадра.
///
/// Внутри диалога нет прокручиваемого списка, поэтому перетаскивание и
/// «щипок» работают на любом устройстве — в отличие от того же виджета
/// внутри `ListView` настроек, где вертикальный жест забирает скролл.
Future<void> showPhotoCropDialog(
  BuildContext context, {
  required String source,
  required PhotoPosition position,
  required double zoom,
  required void Function(PhotoPosition position, double zoom) onChanged,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.scrim,
    builder: (dialogContext) => _PhotoCropDialog(
      source: source,
      position: position,
      zoom: zoom,
      onChanged: onChanged,
    ),
  );
}

class _PhotoCropDialog extends StatefulWidget {
  const _PhotoCropDialog({
    required this.source,
    required this.position,
    required this.zoom,
    required this.onChanged,
  });

  final String source;
  final PhotoPosition position;
  final double zoom;
  final void Function(PhotoPosition position, double zoom) onChanged;

  @override
  State<_PhotoCropDialog> createState() => _PhotoCropDialogState();
}

class _PhotoCropDialogState extends State<_PhotoCropDialog> {
  late PhotoPosition _position;
  late double _zoom;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _zoom = clampPhotoZoom(widget.zoom);
  }

  void _handleChanged(PhotoPosition position, double zoom) {
    setState(() {
      _position = position;
      _zoom = zoom;
    });
    widget.onChanged(position, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.sticker,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.mediaCropField,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InteractivePhotoCrop(
                source: widget.source,
                position: _position,
                zoom: _zoom,
                onChanged: _handleChanged,
                aspectRatio: 4 / 3,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.mediaCropDone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Интерактивное кадрирование: фото двигается пальцем/мышью, масштаб
/// меняется жестом «щипок» (в том числе трекпадом).
///
/// Точка фокуса хранится в процентах (0–100), масштаб — в диапазоне
/// [minPhotoZoom]…[maxPhotoZoom]. Результат отдаётся в [onChanged] в конце
/// жеста, поэтому архив не переписывается на каждом кадре анимации.
class InteractivePhotoCrop extends StatefulWidget {
  const InteractivePhotoCrop({
    super.key,
    required this.source,
    required this.position,
    required this.zoom,
    required this.onChanged,
    this.aspectRatio = 16 / 9,
    this.showExpand = false,
    this.showHint = true,
  });

  final String source;
  final PhotoPosition position;
  final double zoom;
  final void Function(PhotoPosition position, double zoom) onChanged;
  final double aspectRatio;

  /// Показывать кнопку полноэкранного редактора (для превью в форме).
  final bool showExpand;

  /// Показывать компактную подсказку под кадром.
  final bool showHint;

  @override
  State<InteractivePhotoCrop> createState() => _InteractivePhotoCropState();
}

class _InteractivePhotoCropState extends State<InteractivePhotoCrop> {
  late PhotoPosition _position;
  late double _zoom;
  double _startZoom = defaultPhotoZoom;
  Size _viewport = Size.zero;
  bool _gestureActive = false;
  Timer? _scrollCommit;

  @override
  void dispose() {
    _scrollCommit?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _zoom = clampPhotoZoom(widget.zoom);
  }

  @override
  void didUpdateWidget(covariant InteractivePhotoCrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_gestureActive) return;
    if (oldWidget.position != widget.position ||
        oldWidget.zoom != widget.zoom ||
        oldWidget.source != widget.source) {
      _position = widget.position;
      _zoom = clampPhotoZoom(widget.zoom);
    }
  }

  void _commit() => widget.onChanged(_position, _zoom);

  void _onScaleStart(ScaleStartDetails details) {
    _gestureActive = true;
    _startZoom = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_viewport.width <= 0 || _viewport.height <= 0) return;

    final zoom = clampPhotoZoom(_startZoom * details.scale);
    // Двигаем кадр одним пальцем и прокруткой трекпада (scale == 1).
    // Во время щипка (scale != 1) не панорамируем: иначе фокус «уезжает»
    // вместе с центром жеста.
    final isPinching = (details.scale - 1).abs() >= 0.02;
    final next = details.pointerCount <= 1 || !isPinching
        ? panPhotoPosition(
            position: _position,
            dx: details.focalPointDelta.dx,
            dy: details.focalPointDelta.dy,
            viewportWidth: _viewport.width,
            viewportHeight: _viewport.height,
            zoom: zoom,
          )
        : _position;

    setState(() {
      _zoom = zoom;
      _position = next;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _gestureActive = false;
    _commit();
  }

  /// Щипок трекпада приходит по-разному:
  ///  * web — `PointerScaleEvent` (Ctrl+wheel от браузера);
  ///  * Windows/macOS — `PointerPanZoom` (его обрабатывает `GestureDetector`);
  ///  * часть платформ — `Ctrl` + `PointerScrollEvent`.
  ///
  /// Обычное колесо мыши намеренно игнорируем.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScaleEvent) {
      GestureBinding.instance.pointerSignalResolver.register(event, (event) {
        final scaleEvent = event as PointerScaleEvent;
        final factor = scaleEvent.scale;
        if (!factor.isFinite || factor <= 0) return;
        setState(() => _zoom = clampPhotoZoom(_zoom * factor));
        _scheduleCommit();
      });
      return;
    }

    if (event is! PointerScrollEvent) return;
    if (!HardwareKeyboard.instance.isControlPressed) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scroll = event as PointerScrollEvent;
      final delta = scroll.scrollDelta.dy;
      if (delta == 0) return;
      final factor = math.exp(-delta / 200);
      setState(() => _zoom = clampPhotoZoom(_zoom * factor));
      _scheduleCommit();
    });
  }

  /// Сохраняет кадр один раз после серии сигналов трекпада.
  void _scheduleCommit() {
    _scrollCommit?.cancel();
    _scrollCommit = Timer(const Duration(milliseconds: 250), _commit);
  }

  void _reset() {
    setState(() {
      _position = PhotoPosition.center;
      _zoom = defaultPhotoZoom;
    });
    _commit();
  }

  void _openFullScreenEditor() {
    showPhotoCropDialog(
      context,
      source: widget.source,
      position: _position,
      zoom: _zoom,
      onChanged: widget.onChanged,
    );
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                _viewport = constraints.biggest;

                return Listener(
                  onPointerSignal: _onPointerSignal,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
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
                          top: 6,
                          left: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.showExpand) ...[
                                _CropOverlayButton(
                                  tooltip: l10n.mediaCropExpand,
                                  icon: Icons.open_in_full,
                                  onPressed: _openFullScreenEditor,
                                ),
                                const SizedBox(width: 6),
                              ],
                              _CropOverlayButton(
                                tooltip: l10n.mediaCropReset,
                                icon: Icons.restart_alt,
                                onPressed: _reset,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _ZoomBadge(zoom: _zoom),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.showHint)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.mediaCropHint,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: AppColors.inkSoft,
              ),
            ),
          ),
      ],
    );
  }
}

/// Компактная кнопка поверх кадра: не занимает место в раскладке.
class _CropOverlayButton extends StatelessWidget {
  const _CropOverlayButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xAA000000),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ZoomBadge extends StatelessWidget {
  const _ZoomBadge({required this.zoom});

  final double zoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xAA000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${zoom.toStringAsFixed(2)}x',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
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
