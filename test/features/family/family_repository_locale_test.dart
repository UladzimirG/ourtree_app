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
    expect(FamilyRepository.assetFor('be'), 'assets/data/family_be.json');
    expect(FamilyRepository.assetFor('uk'), 'assets/data/family_uk.json');
    expect(FamilyRepository.assetFor('en'), 'assets/data/family_en.json');
    expect(FamilyRepository.assetFor(null), 'assets/data/family_en.json');
    expect(FamilyRepository.assetFor('de'), 'assets/data/family_en.json');
  });

  test('правки хранятся отдельно для каждого языка', () {
    expect(FamilyRepository.storageKeyFor('ru'), 'family_data_ru');
    expect(FamilyRepository.storageKeyFor('be'), 'family_data_be');
    expect(FamilyRepository.storageKeyFor('uk'), 'family_data_uk');
    expect(FamilyRepository.storageKeyFor('en'), 'family_data_en');
    expect(FamilyRepository.storageKeyFor('de'), 'family_data_en');
  });

  test('все демо-версии описывают одну семью из четырёх человек', () {
    final ru = _readArchive(FamilyRepository.assetFor('ru'));

    expect(ru.members, hasLength(4));

    for (final localeName in <String>['ru', 'be', 'uk', 'en']) {
      final data = _readArchive(FamilyRepository.assetFor(localeName));

      expect(data.members, hasLength(4), reason: localeName);
      expect(
        data.members.map((member) => member.id),
        ru.members.map((member) => member.id),
        reason: localeName,
      );
      expect(
        data.timelineEvents.map((event) => event.id),
        ru.timelineEvents.map((event) => event.id),
        reason: localeName,
      );
      expect(data.settings.familySubtitle.trim(), isNotEmpty, reason: localeName);
    }

    // Контент именно переведён, а не скопирован.
    final be = _readArchive(FamilyRepository.assetFor('be'));
    final uk = _readArchive(FamilyRepository.assetFor('uk'));
    final en = _readArchive(FamilyRepository.assetFor('en'));

    expect(be.familyName, isNot(ru.familyName));
    expect(uk.familyName, isNot(ru.familyName));
    expect(en.familyName, isNot(ru.familyName));
    expect(
      en.members.map((member) => member.role),
      isNot(ru.members.map((member) => member.role)),
    );
    expect(
      be.members.map((member) => member.role),
      isNot(ru.members.map((member) => member.role)),
    );
    expect(
      uk.members.map((member) => member.role),
      isNot(ru.members.map((member) => member.role)),
    );
  });

  test('название семьи локализовано в каждом демо-архиве', () {
    final names = <String>{
      for (final localeName in FamilyRepository.demoArchives.keys)
        _readArchive(FamilyRepository.assetFor(localeName)).familyName,
    };

    expect(
      names,
      hasLength(FamilyRepository.demoArchives.length),
      reason: 'название семьи должно отличаться в каждом языке',
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
