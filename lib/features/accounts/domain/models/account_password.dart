import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Соль для локального хеша пароля.
String newPasswordSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64UrlEncode(bytes);
}

/// Хеш пароля для локального входа и переноса в резервную копию.
///
/// Сам пароль нигде не хранится: в аккаунте остаются только соль и SHA-256.
String hashAccountPassword(String password, String salt) {
  return sha256.convert(utf8.encode('$salt:$password')).toString();
}

/// Проверяет пароль по сохранённым соли и хешу.
bool verifyAccountPassword({
  required String password,
  required String? salt,
  required String? hash,
}) {
  if (salt == null || hash == null || salt.isEmpty || hash.isEmpty) {
    return false;
  }
  return hashAccountPassword(password, salt) == hash;
}
