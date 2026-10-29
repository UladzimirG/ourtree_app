import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Проверки словарей: паритет ключей и полнота переводов.
///
/// Файлы читаем напрямую как JSON, чтобы тест падал раньше сборки, если
/// перевод добавили только в один язык.
Map<String, dynamic> _readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  final en = _readArb('lib/l10n/app_en.arb');
  final ru = _readArb('lib/l10n/app_ru.arb');

  test('английский и русский словари содержат одинаковый набор ключей', () {
    final enKeys = _messageKeys(en);
    final ruKeys = _messageKeys(ru);

    expect(
      ruKeys.difference(enKeys),
      isEmpty,
      reason: 'Ключи есть только в ru: добавь их в app_en.arb',
    );
    expect(
      enKeys.difference(ruKeys),
      isEmpty,
      reason: 'Ключи есть только в en: добавь их в app_ru.arb',
    );
  });

  test('у каждого ключа заполнено значение, @-метаданные не расходятся', () {
    for (final arb in <Map<String, dynamic>>[en, ru]) {
      for (final entry in arb.entries) {
        if (entry.key.startsWith('@')) continue;
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: 'Пустое значение у ключа ${entry.key}',
        );
      }
    }

    final enMeta = en.keys.where((key) => key.startsWith('@')).toSet();
    final ruMeta = ru.keys.where((key) => key.startsWith('@')).toSet();

    expect(
      ruMeta.difference(enMeta),
      isEmpty,
      reason: '@-описания есть только в ru',
    );
    expect(
      enMeta.difference(ruMeta),
      isEmpty,
      reason: '@-описания есть только в en',
    );
  });

  test('русские plural-сообщения содержат формы few и many', () {
    final pluralKeys = _messageKeys(ru)
        .where((key) => (ru[key] as String).contains('plural,'))
        .toList();

    expect(pluralKeys, isNotEmpty);
    for (final key in pluralKeys) {
      final value = ru[key] as String;
      expect(value, contains('few{'), reason: 'Нет формы few у $key');
      expect(value, contains('many{'), reason: 'Нет формы many у $key');
      expect(value, contains('other{'), reason: 'Нет формы other у $key');
    }
  });
}
