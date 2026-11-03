import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/config/app_info.dart';

/// Версия на странице «О приложении» должна совпадать с `pubspec.yaml`.
///
/// Иначе после релиза пользователь видит старое значение, а поддержка —
/// неверную сборку.
void main() {
  test('версия приложения совпадает с pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*(\S+)\s*$', multiLine: true).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'В pubspec.yaml нет строки version:');
    expect(match!.group(1), appVersionLabel);
  });

  test('номер сборки — целое число', () {
    expect(appBuildNumber, greaterThan(0));
    expect(appVersionLabel, '$appVersion+$appBuildNumber');
  });
}
