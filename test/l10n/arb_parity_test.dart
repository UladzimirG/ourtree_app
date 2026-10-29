import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Проверки словарей: паритет ключей и полнота переводов.
///
/// Шаблон — `app_en.arb`; каждый остальной язык обязан содержать тот же набор
/// ключей. Файлы читаем напрямую как JSON, чтобы тест падал раньше сборки.
Map<String, dynamic> _readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

String _localeOf(File file) =>
    file.uri.pathSegments.last.replaceAll(RegExp(r'^app_|\.arb$'), '');

/// Переводы без шаблона: `ru`, `be`, `uk` и другие.
final Map<String, Map<String, dynamic>> _translations =
    <String, Map<String, dynamic>>{
  for (final entity in Directory('lib/l10n').listSync())
    if (entity is File &&
        entity.path.endsWith('.arb') &&
        _localeOf(entity) != 'en')
      _localeOf(entity): _readArb(entity.path),
};

void main() {
  final en = _readArb('lib/l10n/app_en.arb');
  final enKeys = _messageKeys(en);

  test('есть переводы для ru, be и uk', () {
    expect(_translations.keys, containsAll(<String>['ru', 'be', 'uk']));
  });

  test('во всех языках тот же набор ключей, что в шаблоне', () {
    for (final translation in _translations.entries) {
      final keys = _messageKeys(translation.value);

      expect(
        keys.difference(enKeys),
        isEmpty,
        reason: 'Лишние ключи в ${translation.key}: их нет в app_en.arb',
      );
      expect(
        enKeys.difference(keys),
        isEmpty,
        reason: 'Нет перевода ${translation.key} для части ключей',
      );
    }
  });

  test('у каждого ключа заполнено значение', () {
    for (final arb in <Map<String, dynamic>>[en, ..._translations.values]) {
      for (final entry in arb.entries) {
        if (entry.key.startsWith('@')) continue;
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: 'Пустое значение у ключа ${entry.key}',
        );
      }
    }
  });

  test('@-описания не расходятся с шаблоном', () {
    final enMeta = en.keys.where((key) => key.startsWith('@')).toSet();
    for (final translation in _translations.entries) {
      final meta = translation.value.keys
          .where((key) => key.startsWith('@'))
          .toSet();
      expect(
        meta.difference(enMeta),
        isEmpty,
        reason: 'Лишние @-описания в ${translation.key}',
      );
    }
  });

  test('plural-сообщения славянских языков содержат формы few и many', () {
    for (final locale in <String>['ru', 'be', 'uk']) {
      final arb = _translations[locale]!;
      final pluralKeys = _messageKeys(arb)
          .where((key) => (arb[key] as String).contains('plural,'))
          .toList();

      expect(pluralKeys, isNotEmpty, reason: 'Нет plural-сообщений в $locale');
      for (final key in pluralKeys) {
        final value = arb[key] as String;
        expect(value, contains('few{'), reason: 'Нет формы few: $locale/$key');
        expect(value, contains('many{'), reason: 'Нет формы many: $locale/$key');
        expect(
          value,
          contains('other{'),
          reason: 'Нет формы other: $locale/$key',
        );
      }
    }
  });
}
