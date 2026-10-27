import 'package:ourtree_app/features/accounts/domain/models/accounts_error.dart';

/// Результат вызова API учётных записей (`AccountsResult<T>`).
///
/// Заменяет пару `{ ok, value/error }` из TypeScript на sealed-класс, чтобы
/// вызывающий код обязан был обработать оба исхода.
sealed class AccountsResult<T> {
  const AccountsResult();

  bool get isSuccess => this is AccountsSuccess<T>;

  bool get isFailure => this is AccountsFailure<T>;

  T? get valueOrNull {
    final result = this;
    return result is AccountsSuccess<T> ? result.value : null;
  }

  AccountsError? get errorOrNull {
    final result = this;
    return result is AccountsFailure<T> ? result.error : null;
  }
}

/// Успешный ответ сервера.
final class AccountsSuccess<T> extends AccountsResult<T> {
  const AccountsSuccess(this.value);

  final T value;
}

/// Ответ сервера с ошибкой.
final class AccountsFailure<T> extends AccountsResult<T> {
  const AccountsFailure(this.error);

  final AccountsError error;
}
