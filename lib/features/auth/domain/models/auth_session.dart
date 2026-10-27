import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';

/// Состояние доступа текущего посетителя (`Session` из `src/lib/auth.ts`).
class AuthSession {
  const AuthSession({
    required this.enabled,
    required this.authenticated,
    this.uid,
    this.role,
    this.name = '',
    this.isGuest = false,
  });

  /// Ответ по умолчанию, когда доступ выключен или сессии ещё нет.
  static const AuthSession anonymous = AuthSession(
    enabled: false,
    authenticated: false,
  );

  /// Включён ли вход в альбом (на сервере есть хотя бы одна учётная запись).
  final bool enabled;

  /// Подтверждена ли текущая сессия сервером.
  final bool authenticated;

  /// Идентификатор учётной записи; `null` для анонимного посетителя.
  final String? uid;

  /// Роль текущего пользователя; `null`, если он не вошёл.
  final UserRole? role;

  /// Отображаемое имя пользователя.
  final String name;

  /// Гость вошёл по одноразовой ссылке и не является владельцем аккаунта.
  final bool isGuest;

  bool get isAdmin => role == UserRole.admin;

  /// Хватает ли прав на действие, требующее [minimum].
  bool can(UserRole minimum) => role?.atLeast(minimum) ?? false;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        enabled: readBool(json['enabled']) ?? false,
        authenticated: readBool(json['authenticated']) ?? false,
        uid: readNullableString(json['uid']),
        role: UserRole.tryParse(json['role']),
        name: readString(json['name']),
        isGuest: readBool(json['isGuest']) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'authenticated': authenticated,
        'uid': uid,
        'role': role?.wireName,
        'name': name,
        'isGuest': isGuest,
      };

  /// Копия с изменёнными полями; `null` означает «оставить как было».
  AuthSession copyWith({
    bool? enabled,
    bool? authenticated,
    String? uid,
    UserRole? role,
    String? name,
    bool? isGuest,
  }) =>
      AuthSession(
        enabled: enabled ?? this.enabled,
        authenticated: authenticated ?? this.authenticated,
        uid: uid ?? this.uid,
        role: role ?? this.role,
        name: name ?? this.name,
        isGuest: isGuest ?? this.isGuest,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          enabled == other.enabled &&
          authenticated == other.authenticated &&
          uid == other.uid &&
          role == other.role &&
          name == other.name &&
          isGuest == other.isGuest;

  @override
  int get hashCode =>
      Object.hash(enabled, authenticated, uid, role, name, isGuest);
}
