import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/media/presentation/widgets/interactive_photo_crop.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

Widget _host({
  required void Function(PhotoPosition position, double zoom) onChanged,
}) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: InteractivePhotoCrop(
            source: '',
            position: PhotoPosition.center,
            zoom: 1,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('кадр управляется жестами, без ползунков', (tester) async {
    PhotoPosition? position;
    double? zoom;

    await tester.pumpWidget(
      _host(onChanged: (nextPosition, nextZoom) {
        position = nextPosition;
        zoom = nextZoom;
      }),
    );

    expect(find.byType(Slider), findsNothing);
    expect(find.byIcon(Icons.zoom_in), findsNothing);
    expect(find.byIcon(Icons.zoom_out), findsNothing);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);

    await tester.drag(
      find.descendant(
        of: find.byType(InteractivePhotoCrop),
        matching: find.byType(AspectRatio),
      ),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();

    expect(position, isNotNull);
    // Движение вправо открывает левую часть кадра.
    expect(position!.x, lessThan(50));
    expect(zoom, 1);
  });

  testWidgets('сброс возвращает центр и масштаб 1', (tester) async {
    PhotoPosition? position;
    double? zoom;

    await tester.pumpWidget(
      _host(onChanged: (nextPosition, nextZoom) {
        position = nextPosition;
        zoom = nextZoom;
      }),
    );

    await tester.drag(
      find.descendant(
        of: find.byType(InteractivePhotoCrop),
        matching: find.byType(AspectRatio),
      ),
      const Offset(0, 30),
    );
    await tester.pumpAndSettle();
    expect(position!.y, lessThan(50));

    await tester.tap(find.byIcon(Icons.restart_alt));
    await tester.pumpAndSettle();

    expect(position, PhotoPosition.center);
    expect(zoom, 1);
  });
}
