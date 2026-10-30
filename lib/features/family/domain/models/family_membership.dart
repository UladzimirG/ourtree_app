import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';

/// Роль члена семьи в облаке.
///
/// Владелец платит и управляет составом, поэтому в Firestore он хранится как
/// `owner`, а в UI-правах разворачивается в `UserRole.admin`.
enum FamilyRole {
  owner('owner', UserRole.admin),
  editor('editor', UserRole.editor),
  viewer('viewer', UserRole.viewer);

  const FamilyRole(this.wireName, this.userRole);

  final String wireName;
  final UserRole userRole;

  bool get canEdit => this != FamilyRole.viewer;

  static FamilyRole fromWire(Object? value) {
    for (final role in values) {
      if (role.wireName == value) return role;
    }
    return FamilyRole.viewer;
  }

  /// Роль, которую увидит существующий слой прав (`access_provider.dart`).
  UserRole toUserRole() => userRole;
}

/// Статус членства: удалённый участник остаётся документом-надгробием,
/// чтобы синхронизация не «воскрешала» его на других устройствах.
enum FamilyMembershipStatus {
  active('active'),
  removed('removed');

  const FamilyMembershipStatus(this.wireName);

  final String wireName;

  static FamilyMembershipStatus fromWire(Object? value) =>
      value == FamilyMembershipStatus.removed.wireName
          ? FamilyMembershipStatus.removed
          : FamilyMembershipStatus.active;
}

/// Документ `families/{familyId}/members/{userId}`.
class FamilyMembership {
  const FamilyMembership({
    required this.userId,
    required this.authUid,
    this.displayName = '',
    this.role = FamilyRole.viewer,
    this.allMembersVisible = true,
    this.visiblePersonIds = const <String>[],
    this.status = FamilyMembershipStatus.active,
    this.joinedAt = 0,
    this.updatedAt = 0,
    this.deletedAt,
  });

  final String userId;
  final String authUid;
  final String displayName;
  final FamilyRole role;

  /// Владелец и редактор видят всех; наблюдателю можно ограничить состав.
  final bool allMembersVisible;
  final List<String> visiblePersonIds;

  final FamilyMembershipStatus status;
  final int joinedAt;
  final int updatedAt;
  final int? deletedAt;

  bool get isOwner => role == FamilyRole.owner;

  bool get isActive => status == FamilyMembershipStatus.active;

  /// Виден ли участник [personId] этому пользователю.
  bool canSeePerson(String personId) =>
      isOwner || allMembersVisible || visiblePersonIds.contains(personId);

  /// Документ владельца семьи.
  ///
  /// [authUid] обязателен: по нему Storage/Firestore проверяют доступ к файлам
  /// через `families/{fid}/members/{authUid}`.
  factory FamilyMembership.owner({
    required String userId,
    required String authUid,
    required int now,
    String displayName = '',
  }) =>
      FamilyMembership(
        userId: userId,
        authUid: authUid,
        displayName: displayName,
        role: FamilyRole.owner,
        status: FamilyMembershipStatus.active,
        joinedAt: now,
        updatedAt: now,
      );

  factory FamilyMembership.fromJson(Map<String, dynamic> json) =>
      FamilyMembership(
        userId: readString(json['userId']),
        authUid: readString(json['authUid']),
        displayName: readString(json['displayName']),
        role: FamilyRole.fromWire(json['role']),
        allMembersVisible: readBool(json['allMembersVisible']) ?? true,
        visiblePersonIds: readStringList(json['visiblePersonIds']),
        status: FamilyMembershipStatus.fromWire(json['status']),
        joinedAt: readInt(json['joinedAt']) ?? 0,
        updatedAt: readInt(json['updatedAt']) ?? 0,
        deletedAt: readInt(json['deletedAt']),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'authUid': authUid,
        if (displayName.isNotEmpty) 'displayName': displayName,
        'role': role.wireName,
        'allMembersVisible': allMembersVisible,
        if (visiblePersonIds.isNotEmpty)
          'visiblePersonIds': visiblePersonIds,
        'status': status.wireName,
        if (joinedAt > 0) 'joinedAt': joinedAt,
        'updatedAt': updatedAt,
        if (deletedAt != null) 'deletedAt': deletedAt,
      };

  FamilyMembership copyWith({
    String? userId,
    String? authUid,
    String? displayName,
    FamilyRole? role,
    bool? allMembersVisible,
    List<String>? visiblePersonIds,
    FamilyMembershipStatus? status,
    int? joinedAt,
    int? updatedAt,
    int? Function()? deletedAt,
  }) =>
      FamilyMembership(
        userId: userId ?? this.userId,
        authUid: authUid ?? this.authUid,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        allMembersVisible: allMembersVisible ?? this.allMembersVisible,
        visiblePersonIds: visiblePersonIds ?? this.visiblePersonIds,
        status: status ?? this.status,
        joinedAt: joinedAt ?? this.joinedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == null ? this.deletedAt : deletedAt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMembership &&
          userId == other.userId &&
          authUid == other.authUid &&
          displayName == other.displayName &&
          role == other.role &&
          allMembersVisible == other.allMembersVisible &&
          listsEqual(visiblePersonIds, other.visiblePersonIds) &&
          status == other.status &&
          joinedAt == other.joinedAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
        userId,
        authUid,
        displayName,
        role,
        allMembersVisible,
        listsHash(visiblePersonIds),
        status,
        joinedAt,
        updatedAt,
        deletedAt,
      );
}
