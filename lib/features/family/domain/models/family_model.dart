import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/family/domain/models/family_limits.dart';
import 'package:ourtree_app/features/family/domain/models/premium_status.dart';
import 'package:ourtree_app/features/settings/domain/models/family_settings.dart';

/// Документ `families/{familyId}` — то, что нужно знать до загрузки содержимого.
///
/// Содержимое (`people`, `events`, `media`) живёт в подколлекциях: так документ
/// семьи не упирается в лимит Firestore в 1 МиБ и не перетирается целиком при
/// одновременной правке с двух устройств.
class FamilyModel {
  const FamilyModel({
    required this.id,
    required this.name,
    required this.ownerUserId,
    this.ownerAuthUid = '',
    this.memberIds = const <String>[],
    this.memberUids = const <String>[],
    this.revision = 0,
    this.createdAt = 0,
    this.updatedAt = 0,
    this.premium = const PremiumStatus.inactive(),
    this.settings =
        const FamilySettings(familyName: FamilySettings.fallbackName),
    this.schemaVersion = currentFamilySchemaVersion,
  });

  /// Версия схемы документа семьи.
  static const int currentFamilySchemaVersion = 1;

  /// UUID v4 семьи; он же `appUserID` в RevenueCat.
  final String id;

  final String name;

  /// `userId` владельца — единственного, кто может платить и менять состав.
  final String ownerUserId;

  /// `auth.uid` владельца: именно его проверяют Security Rules, потому что
  /// локальный [ownerUserId] клиент может подставить любой.
  final String ownerAuthUid;

  /// Денормализованные списки: по ним строятся Security Rules без `get()`
  /// лишних документов.
  final List<String> memberIds;
  final List<String> memberUids;

  /// Счётчик изменений для диагностики рассинхрона.
  final int revision;

  final int createdAt;

  /// Время последнего изменения (по серверу), мс эпохи.
  final int updatedAt;

  final PremiumStatus premium;

  /// «Шапка» семьи: название, подзаголовок, общее фото, флаги отображения.
  final FamilySettings settings;

  final int schemaVersion;

  bool isMember(String userId) => memberIds.contains(userId);

  bool isAuthMember(String authUid) =>
      authUid.isNotEmpty && memberUids.contains(authUid);

  bool isOwner(String userId) => ownerUserId == userId;

  /// Активен ли премиум на момент [now].
  bool premiumActiveAt(DateTime now) => premium.isActiveAt(now);

  /// Сколько человек ещё можно пригласить.
  int freeSlots({required DateTime now}) {
    final limit = familyMemberLimit(premium: premiumActiveAt(now));
    final left = limit - memberIds.length;
    return left < 0 ? 0 : left;
  }

  /// Новая семья, созданная пользователем [ownerUserId] (auth-uid [ownerAuthUid]).
  ///
  /// Денормализованные списки заполняются сразу: по ним работают Security Rules,
  /// поэтому первый же запрос владельца уже проходит проверку членства.
  factory FamilyModel.created({
    required String id,
    required String name,
    required String ownerUserId,
    required String ownerAuthUid,
    required int now,
    FamilySettings? settings,
  }) {
    final trimmed = name.trim();
    final familyName =
        trimmed.isEmpty ? FamilySettings.fallbackName : trimmed;
    return FamilyModel(
      id: id,
      name: familyName,
      ownerUserId: ownerUserId,
      ownerAuthUid: ownerAuthUid,
      memberIds: <String>[ownerUserId],
      memberUids: <String>[ownerAuthUid],
      revision: 1,
      createdAt: now,
      updatedAt: now,
      settings: settings ?? FamilySettings(familyName: familyName),
    );
  }

  factory FamilyModel.fromJson(Map<String, dynamic> json) => FamilyModel(
        id: readString(json['id']),
        name: readString(json['name'], fallback: FamilySettings.fallbackName),
        ownerUserId: readString(json['ownerUserId']),
        ownerAuthUid: readString(json['ownerAuthUid']),
        memberIds: readStringList(json['memberIds']),
        memberUids: readStringList(json['memberUids']),
        revision: readInt(json['revision']) ?? 0,
        createdAt: readInt(json['createdAt']) ?? 0,
        updatedAt: readInt(json['updatedAt']) ?? 0,
        premium: PremiumStatus.fromJson(
          readMap(json['premium']) ?? const <String, dynamic>{},
        ),
        settings: FamilySettings.fromJson(
          readMap(json['settings']) ?? const <String, dynamic>{},
        ),
        schemaVersion:
            readInt(json['schemaVersion']) ?? currentFamilySchemaVersion,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerUserId': ownerUserId,
        'ownerAuthUid': ownerAuthUid,
        'memberIds': memberIds,
        'memberUids': memberUids,
        'revision': revision,
        if (createdAt > 0) 'createdAt': createdAt,
        'updatedAt': updatedAt,
        'premium': premium.toJson(),
        'settings': settings.toJson(),
        'schemaVersion': schemaVersion,
      };

  FamilyModel copyWith({
    String? id,
    String? name,
    String? ownerUserId,
    String? ownerAuthUid,
    List<String>? memberIds,
    List<String>? memberUids,
    int? revision,
    int? createdAt,
    int? updatedAt,
    PremiumStatus? premium,
    FamilySettings? settings,
    int? schemaVersion,
  }) =>
      FamilyModel(
        id: id ?? this.id,
        name: name ?? this.name,
        ownerUserId: ownerUserId ?? this.ownerUserId,
        ownerAuthUid: ownerAuthUid ?? this.ownerAuthUid,
        memberIds: memberIds ?? this.memberIds,
        memberUids: memberUids ?? this.memberUids,
        revision: revision ?? this.revision,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        premium: premium ?? this.premium,
        settings: settings ?? this.settings,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyModel &&
          id == other.id &&
          name == other.name &&
          ownerUserId == other.ownerUserId &&
          ownerAuthUid == other.ownerAuthUid &&
          listsEqual(memberIds, other.memberIds) &&
          listsEqual(memberUids, other.memberUids) &&
          revision == other.revision &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          premium == other.premium &&
          settings == other.settings &&
          schemaVersion == other.schemaVersion;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        ownerUserId,
        ownerAuthUid,
        listsHash(memberIds),
        listsHash(memberUids),
        revision,
        createdAt,
        updatedAt,
        premium,
        settings,
        schemaVersion,
      );
}
