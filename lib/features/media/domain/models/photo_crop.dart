import 'dart:math' as math;

import 'package:ourtree_app/features/profile/domain/models/photo_position.dart';

/// Масштаб по умолчанию: кадр показывается ровно так, как его вписывает
/// `BoxFit.cover`, без дополнительного увеличения.
///
/// Раньше в разных виджетах встречались разные значения (`1`, `1.4`),
/// из-за чего редактор кадра и плитки показывали разный снимок.
const double defaultPhotoZoom = 1.0;

/// Минимальный масштаб: меньше единицы нельзя — вокруг фото появились бы поля.
const double minPhotoZoom = 1.0;

/// Максимальный масштаб: позволяет «подтянуть» лицо на групповом снимке.
const double maxPhotoZoom = 6.0;

/// Доля кадра, на которую приходится полный ход точки фокуса при масштабе 1.
///
/// При `zoom == 1` собственного «запаса» у снимка в `BoxFit.cover` может не
/// быть (или он есть только по одной оси), поэтому двигать кадр всё равно
/// нужно: чувствительность ограничиваем этим значением, иначе один пиксель
/// сдвигал бы фото на десятки процентов.
const double photoPanFallbackSpan = 0.6;

/// Приводит масштаб к допустимому диапазону [minPhotoZoom]…[maxPhotoZoom].
double clampPhotoZoom(double zoom) {
  if (!zoom.isFinite) return defaultPhotoZoom;
  if (zoom <= minPhotoZoom) return minPhotoZoom;
  if (zoom >= maxPhotoZoom) return maxPhotoZoom;
  return zoom;
}

/// Масштаб с учётом значения по умолчанию для пустых данных.
double photoZoomOrDefault(double? zoom) =>
    clampPhotoZoom(zoom ?? defaultPhotoZoom);

/// Сдвигает точку фокуса на смещение пальца/мыши [dx]/[dy].
///
/// Возвращает новую позицию в процентах (0–100). Зависимость от масштаба
/// обратная: чем сильнее увеличение, тем точнее движение.
PhotoPosition panPhotoPosition({
  required PhotoPosition position,
  required double dx,
  required double dy,
  required double viewportWidth,
  required double viewportHeight,
  required double zoom,
}) {
  if (viewportWidth <= 0 || viewportHeight <= 0) return position;

  final span = math.max(zoom - 1, photoPanFallbackSpan);
  final spanX = span * viewportWidth;
  final spanY = span * viewportHeight;

  return PhotoPosition(
    x: (position.x - dx / spanX * 100).clamp(0, 100).toDouble(),
    y: (position.y - dy / spanY * 100).clamp(0, 100).toDouble(),
  );
}
