import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/media/domain/models/photo_crop.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

void main() {
  group('масштаб кадра', () {
    test('ограничен допустимым диапазоном', () {
      expect(clampPhotoZoom(0.2), minPhotoZoom);
      expect(clampPhotoZoom(99), maxPhotoZoom);
      expect(clampPhotoZoom(double.nan), defaultPhotoZoom);
      expect(clampPhotoZoom(double.infinity), defaultPhotoZoom);
    });

    test('пустое значение заменяется значением по умолчанию', () {
      expect(photoZoomOrDefault(null), defaultPhotoZoom);
      expect(photoZoomOrDefault(2.5), 2.5);
      expect(photoZoomOrDefault(0), minPhotoZoom);
    });

    test('диапазон позволяет увеличить кадр заметно сильнее прежнего', () {
      // Раньше максимум был 3.0 — «подтянуть» лицо было нельзя.
      expect(maxPhotoZoom, greaterThanOrEqualTo(5.0));
      expect(minPhotoZoom, 1.0);
    });
  });

  group('сдвиг видимой части', () {
    const start = PhotoPosition(x: 50, y: 50);

    PhotoPosition pan({
      double dx = 0,
      double dy = 0,
      double zoom = 2,
      double width = 300,
      double height = 200,
    }) =>
        panPhotoPosition(
          position: start,
          dx: dx,
          dy: dy,
          viewportWidth: width,
          viewportHeight: height,
          zoom: zoom,
        );

    test('движение вправо открывает левую часть кадра', () {
      final moved = pan(dx: 60);
      expect(moved.x, lessThan(50));
      expect(moved.y, closeTo(50, 0.001));
    });

    test('движение вниз открывает верхнюю часть кадра', () {
      final moved = pan(dy: 40);
      expect(moved.y, lessThan(50));
      expect(moved.x, closeTo(50, 0.001));
    });

    test('касание на границе не выходит за 0…100', () {
      final clamped = pan(dx: 100000, dy: 100000, zoom: 1);
      expect(clamped.x, 0);
      expect(clamped.y, 0);

      final other = pan(dx: -100000, dy: -100000, zoom: 1);
      expect(other.x, 100);
      expect(other.y, 100);
    });

    test('при масштабе 1 кадр всё равно двигается', () {
      // Раньше при zoom == 1 сдвиг блокировался полностью.
      expect(pan(dx: 30, zoom: minPhotoZoom).x, lessThan(50));
    });

    test('чем больше масштаб, тем точнее движение', () {
      double shift(double zoom) => 50 - pan(dx: 30, zoom: zoom).x;

      expect(shift(4), greaterThan(0));
      expect(shift(4), lessThan(shift(2)));
    });

    test('нулевой размер кадра не меняет позицию', () {
      final result = panPhotoPosition(
        position: start,
        dx: 10,
        dy: 10,
        viewportWidth: 0,
        viewportHeight: 0,
        zoom: 2,
      );
      expect(result, start);
    });
  });
}