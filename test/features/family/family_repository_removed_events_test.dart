import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => MediaStorage.instance.clearForTests());

  test('saved archive no longer contains removed demo events', () async {
    final saved = jsonEncode({
      'familyName': 'Family',
      'members': <Object>[],
      'timelineEvents': [
        for (final id in FamilyRepository.removedEventIds)
          {'id': id, 'date': '2011-03-08', 'title': id, 'kind': 'birth'},
        {'id': 'meet', 'date': '2013-10-01', 'title': 'Знакомство'},
      ],
    });
    await MediaStorage.instance.putString(FamilyRepository.storageKey, saved);

    final data = await const FamilyRepository().loadFamilyData();

    expect(data.timelineEvents.map((event) => event.id), ['meet']);
  });
}
