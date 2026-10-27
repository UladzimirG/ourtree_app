/// Роль пользователя в семейном альбоме (`Role` из `src/lib/auth.ts`).
///
/// Порядок объявления важен: `viewer < editor < admin`. Ранг используется во
/// всех проверках «хватает ли прав на действие».
enum UserRole {
  viewer('viewer', 0),
  editor('editor', 1),
  admin('admin', 2);

  const UserRole(this.wireName, this.rank);

  /// Значение, которое приходит в JSON и уходит на сервер.
  final String wireName;

  /// Числовой вес роли для сравнения.
  final int rank;

  /// Разбирает роль из JSON; `null`, если значение неизвестно.
  static UserRole? tryParse(Object? value) {
    for (final role in values) {
      if (role.wireName == value) return role;
    }
    return null;
  }

  /// `true`, если роль не ниже [minimum].
  bool atLeast(UserRole minimum) => rank >= minimum.rank;
}
