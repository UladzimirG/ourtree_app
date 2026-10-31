import 'package:ourtree_app/core/utils/ids.dart';

/// Код приглашения в семью.
///
/// Алфавит совпадает с генератором в `ids.dart`: без похожих символов
/// (0/O, 1/I/L), поэтому код можно продиктовать голосом.
class InviteCode {
  const InviteCode._();

  static const int length = 8;

  static const String alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static final RegExp _pattern = RegExp('^[$alphabet]{$length}\$');

  /// Приводит пользовательский ввод к каноническому виду:
  /// верхний регистр, без пробелов, дефисов и подчёркиваний.
  static String normalize(String raw) =>
      raw.toUpperCase().replaceAll(RegExp(r'[\s\-_]'), '');

  static bool isValid(String code) => _pattern.hasMatch(code);

  static String generate() => newInviteCode(length);
}
