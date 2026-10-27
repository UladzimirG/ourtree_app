/// Итог входа (`SignInResult` из `src/lib/auth.ts`).
enum SignInResult {
  ok('ok'),
  wrong('wrong'),
  locked('locked'),
  error('error');

  const SignInResult(this.wireName);

  /// Значение, которым результат обозначен в исходном API.
  final String wireName;

  bool get isSuccess => this == SignInResult.ok;

  static SignInResult fromWire(Object? value) {
    for (final result in values) {
      if (result.wireName == value) return result;
    }
    return SignInResult.error;
  }
}

/// Итог принятия гостевой ссылки (`GuestResult` из `src/lib/auth.ts`).
enum GuestResult {
  ok('ok'),
  invalid('invalid'),
  error('error');

  const GuestResult(this.wireName);

  /// Значение, которым результат обозначен в исходном API.
  final String wireName;

  bool get isSuccess => this == GuestResult.ok;

  static GuestResult fromWire(Object? value) {
    for (final result in values) {
      if (result.wireName == value) return result;
    }
    return GuestResult.error;
  }
}
