import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_header.dart';

void main() {
  Future<void> pumpHeader(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FamilyHeader(
              familyName: 'Семья Орловых',
              familyPhoto: null,
              settingsTooltip: 'Настройки',
              onSettingsTap: () {},
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('на телефоне название семьи видно, а действия уезжают ниже', (
    tester,
  ) async {
    await pumpHeader(tester, 390);

    expect(tester.takeException(), isNull);
    // Две строки вместо одной: так подпись не сжимается до «О…».
    final title = tester.widget<Text>(find.text('Семья Орловых'));
    expect(title.maxLines, 2);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('на широком экране шапка остаётся в одну строку', (tester) async {
    await pumpHeader(tester, 900);

    expect(tester.takeException(), isNull);
    final title = tester.widget<Text>(find.text('Семья Орловых'));
    expect(title.maxLines, 1);
  });
}
