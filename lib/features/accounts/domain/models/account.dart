import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';

/// Учётная запись семейного альбома (`Account` из `src/lib/accounts.ts`).
class Account {
  const Account({
    required this.id,
    required this.login,
    required this.name,
    required this.role,
    this.createdAt = 0,
    this.allMembersVisible = true,
    this.visibleMemberIds = const <String>[],
    this.passwordHash,
    this.passwordSalt,
  });

  final String id;
  final String login;
  final String name;

  /// Роль доступа; неизвестное значение сервера трактуется как `viewer`.
  final UserRole role;

  /// Время создания в миллисекундах с начала эпохи.
  final int createdAt;

  /// Администратор видит весь архив без ограничений.
  final bool allMembersVisible;

  /// Участники, доступные аккаунту, если [allMembersVisible] выключен.
  final List<String> visibleMemberIds;

  /// SHA-256 пароля и соль; сам пароль не хранится.
  final String? passwordHash;
  final String? passwordSalt;

  bool get isAdmin => role == UserRole.admin;

  bool get canEdit => role != UserRole.viewer;

  /// Виден ли аккаунту участник [memberId].
  bool canSeeMember(String memberId) =>
      isAdmin || allMembersVisible || visibleMemberIds.contains(memberId);

  factory Account.fromJson(Map<String, dynamic> json) {
    final login = readString(json['login']);
    return Account(
      id: readString(json['id']),
      login: login,
      name: readString(json['name'], fallback: login),
      role: UserRole.tryParse(json['role']) ?? UserRole.viewer,
      createdAt: readInt(json['createdAt']) ?? 0,
      allMembersVisible: readBool(json['allMembersVisible']) ?? true,
      visibleMemberIds: readStringList(json['visibleMemberIds']),
      passwordHash: readNullableString(json['passwordHash']),
      passwordSalt: readNullableString(json['passwordSalt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'login': login,
        'name': name,
        'role': role.wireName,
        'createdAt': createdAt,
        'allMembersVisible': allMembersVisible,
        if (visibleMemberIds.isNotEmpty)
          'visibleMemberIds': visibleMemberIds,
        if (passwordHash != null) 'passwordHash': passwordHash,
        if (passwordSalt != null) 'passwordSalt': passwordSalt,
      };

  Account copyWith({
    String? id,
    String? login,
    String? name,
    UserRole? role,
    int? createdAt,
    bool? allMembersVisible,
    List<String>? visibleMemberIds,
    String? passwordHash,
    String? passwordSalt,
  }) =>
      Account(
        id: id ?? this.id,
        login: login ?? this.login,
        name: name ?? this.name,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        allMembersVisible: allMembersVisible ?? this.allMembersVisible,
        visibleMemberIds: visibleMemberIds ?? this.visibleMemberIds,
        passwordHash: passwordHash ?? this.passwordHash,
        passwordSalt: passwordSalt ?? this.passwordSalt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          id == other.id &&
          login == other.login &&
          name == other.name &&
          role == other.role &&
          createdAt == other.createdAt &&
          allMembersVisible == other.allMembersVisible &&
          listsEqual(visibleMemberIds, other.visibleMemberIds) &&
          passwordHash == other.passwordHash &&
          passwordSalt == other.passwordSalt;

  @override
  int get hashCode => Object.hash(
        id,
        login,
        name,
        role,
        createdAt,
        allMembersVisible,
        Object.hashAll(visibleMemberIds),
        passwordHash,
        passwordSalt,
      );
}

/// Данные для создания учётной записи (`AccountInput`).
class AccountInput {
  const AccountInput({
    required this.login,
    required this.name,
    required this.password,
    required this.role,
  });

  final String login;
  final String name;
  final String password;
  final UserRole role;

  Map<String, dynamic> toJson() => {
        'login': login,
        'name': name,
        'password': password,
        'role': role.wireName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountInput &&
          login == other.login &&
          name == other.name &&
          password == other.password &&
          role == other.role;

  @override
  int get hashCode => Object.hash(login, name, password, role);
}

/// Поля, которые принимает PATCH (`AccountPatch`).
///
/// `password == null` означает «оставить текущий пароль».
class AccountPatch {
  const AccountPatch({
    this.name,
    this.role,
    this.password,
  });

  final String? name;
  final UserRole? role;
  final String? password;

  bool get isEmpty => name == null && role == null && password == null;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (role != null) 'role': role!.wireName,
        if (password != null) 'password': password,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountPatch &&
          name == other.name &&
          role == other.role &&
          password == other.password;

  @override
  int get hashCode => Object.hash(name, role, password);
}
