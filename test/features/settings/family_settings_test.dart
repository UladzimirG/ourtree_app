import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/settings/domain/models/family_settings.dart';

void main() {
  test('по умолчанию название считается демо-значением', () {
    final settings = FamilySettings.fromJson(<String, dynamic>{
      'familyName': 'Our Tree',
      'familySubtitle': 'Seven branches of one tree',
    });

    expect(settings.nameIsCustom, isFalse);
    expect(settings.subtitleIsCustom, isFalse);
  });

  test('флаги ручной правки переживают JSON', () {
    const settings = FamilySettings(
      familyName: 'My family',
      nameIsCustom: true,
      familySubtitle: 'Custom subtitle',
      subtitleIsCustom: true,
    );

    final json = settings.toJson();
    expect(json['nameIsCustom'], isTrue);
    expect(json['subtitleIsCustom'], isTrue);

    final restored = FamilySettings.fromJson(json);
    expect(restored.nameIsCustom, isTrue);
    expect(restored.subtitleIsCustom, isTrue);
    expect(restored, settings);
  });

  test('демо-значения не помечаются в JSON как правка', () {
    const settings = FamilySettings(familyName: 'Our Tree');
    final json = settings.toJson();

    expect(json.containsKey('nameIsCustom'), isFalse);
    expect(json.containsKey('subtitleIsCustom'), isFalse);
  });
}
