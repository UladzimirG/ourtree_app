import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';

FamilyData _readArchive(String path) => FamilyData.fromJson(
      (jsonDecode(File(path).readAsStringSync()) as Map)
          .cast<String, dynamic>(),
    );

void main() {
  test('выбирает демо-архив по языку интерфейса', () {
    expect(FamilyRepository.assetFor('ru'), 'assets/data/family_ru.json');
    expect(FamilyRepository.assetFor('en'), 'assets/data/family_en.json');
    expect(FamilyRepository.assetFor(null), 'assets/data/family_ru.json');
    expect(FamilyRepository.assetFor('de'), 'assets/data/family_ru.json');
  });

  test('правки хранятся отдельно для каждого языка', () {
    expect(FamilyRepository.storageKeyFor('ru'), 'family_data_ru');
    expect(FamilyRepository.storageKeyFor('en'), 'family_data_en');
    expect(FamilyRepository.storageKeyFor('de'), 'family_data_ru');
  });

  test('обе демо-версии описывают одну семью из четырёх человек', () {
    final ru = _readArchive(FamilyRepository.assetFor('ru'));
    final en = _readArchive(FamilyRepository.assetFor('en'));

    expect(ru.members, hasLength(4));
    expect(en.members, hasLength(4));
    expect(
      en.members.map((member) => member.id),
      ru.members.map((member) => member.id),
    );
    expect(
      en.timelineEvents.map((event) => event.id),
      ru.timelineEvents.map((event) => event.id),
    );

    // Контент именно переведён, а не скопирован.
    expect(en.familyName, isNot(ru.familyName));
    expect(
      en.members.map((member) => member.role),
      isNot(ru.members.map((member) => member.role)),
    );
  });

  test('у каждого участника есть имя, роль и дата рождения', () {
    for (final localeName in FamilyRepository.demoArchives.keys) {
      final data = _readArchive(FamilyRepository.assetFor(localeName));
      for (final member in data.members) {
        expect(member.name.trim(), isNotEmpty, reason: '$localeName/${member.id}');
        expect(member.role.trim(), isNotEmpty, reason: '$localeName/${member.id}');
        expect(member.birthdayDate, isNotNull, reason: '$localeName/${member.id}');
      }
    }
  });
}
