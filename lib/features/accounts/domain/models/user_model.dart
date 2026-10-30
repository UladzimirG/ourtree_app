import 'package:ourtree_app/core/utils/json_reader.dart';

/// Облачная личность устройства.
///
/// Связывает локальный аккаунт (`Account` с логином и паролем) с анонимным
/// Firebase Auth. Пароль и его хеш остаются только на устройстве и в облако
/// не попадают.
class UserModel {
  const UserModel({
    required this.id,
    this.authUid = '',
    this.displayName = '',
    this.createdAt = 0,
    this.lastSeenAt = 0,
    this.activeFamilyId,
    this.schemaVersion = currentUserSchemaVersion,
  });

  /// Версия схемы документа `users/{userId}`.
  static const int currentUserSchemaVersion = 1;

  /// UUID v4 — совпадает с id документа `users/{userId}`.
  final String id;

  /// UID анонимной Firebase Auth; пустая строка, пока вход не выполнен.
  final String authUid;

  final String displayName;

  /// Время создания/последней активности в миллисекундах эпохи.
  final int createdAt;
  final int lastSeenAt;

  /// Семья, открытая на этом устройстве.
  final String? activeFamilyId;

  final int schemaVersion;

  bool get isLinked => authUid.isNotEmpty;

  bool hasFamily([String? familyId]) =>
      activeFamilyId != null &&
      (familyId == null || activeFamilyId == familyId);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: readString(json['id']),
        authUid: readString(json['authUid']),
        displayName: readString(json['displayName']),
        createdAt: readInt(json['createdAt']) ?? 0,
        lastSeenAt: readInt(json['lastSeenAt']) ?? 0,
        activeFamilyId: readNullableString(json['activeFamilyId']),
        schemaVersion:
            readInt(json['schemaVersion']) ?? currentUserSchemaVersion,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (authUid.isNotEmpty) 'authUid': authUid,
        if (displayName.isNotEmpty) 'displayName': displayName,
        if (createdAt > 0) 'createdAt': createdAt,
        if (lastSeenAt > 0) 'lastSeenAt': lastSeenAt,
        if (activeFamilyId != null && activeFamilyId!.isNotEmpty)
          'activeFamilyId': activeFamilyId,
        'schemaVersion': schemaVersion,
      };

  UserModel copyWith({
    String? id,
    String? authUid,
    String? displayName,
    int? createdAt,
    int? lastSeenAt,
    String? Function()? activeFamilyId,
    int? schemaVersion,
  }) =>
      UserModel(
        id: id ?? this.id,
        authUid: authUid ?? this.authUid,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt ?? this.createdAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        activeFamilyId:
            activeFamilyId == null ? this.activeFamilyId : activeFamilyId(),
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          id == other.id &&
          authUid == other.authUid &&
          displayName == other.displayName &&
          createdAt == other.createdAt &&
          lastSeenAt == other.lastSeenAt &&
          activeFamilyId == other.activeFamilyId &&
          schemaVersion == other.schemaVersion;

  @override
  int get hashCode => Object.hash(
        id,
        authUid,
        displayName,
        createdAt,
        lastSeenAt,
        activeFamilyId,
        schemaVersion,
      );
}
