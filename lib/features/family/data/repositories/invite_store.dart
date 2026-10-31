import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourtree_app/features/family/domain/models/family_membership.dart';
import 'package:ourtree_app/features/family/domain/models/invite_code.dart';

/// Приглашение, найденное по коду.
class InviteInfo {
  const InviteInfo({
    required this.code,
    required this.familyId,
    required this.revoked,
    required this.expiresAt,
  });

  final String code;
  final String familyId;
  final bool revoked;

  /// Время истечения в миллисекундах эпохи.
  final int expiresAt;

  bool isExpiredAt(DateTime now) => expiresAt <= now.millisecondsSinceEpoch;

  bool isValidAt(DateTime now) => !revoked && !isExpiredAt(now);

  factory InviteInfo.fromJson(String code, Map<String, dynamic> json) {
    final rawExpires = json['expiresAt'];
    return InviteInfo(
      code: code,
      familyId: json['familyId'] is String ? json['familyId'] as String : '',
      revoked: json['revoked'] == true,
      expiresAt: rawExpires is num ? rawExpires.toInt() : 0,
    );
  }
}

/// Хранилище кодов приглашений (`inviteCodes/{code}`).
abstract class InviteStore {
  /// Создаёт код для семьи [familyId]. Возвращает сам код.
  Future<String> create({
    required String familyId,
    required String createdByAuthUid,
    FamilyRole role = FamilyRole.editor,
    Duration ttl = const Duration(days: 14),
  });

  Future<InviteInfo?> find(String code);
}

/// Реализация поверх Cloud Firestore.
class FirestoreInviteStore implements InviteStore {
  FirestoreInviteStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String collection = 'inviteCodes';

  @override
  Future<String> create({
    required String familyId,
    required String createdByAuthUid,
    FamilyRole role = FamilyRole.editor,
    Duration ttl = const Duration(days: 14),
  }) async {
    // Код генерируется на клиенте: правило проверяет, что создатель — владелец
    // семьи, поэтому подделать чужой инвайт нельзя.
    var code = InviteCode.generate();
    for (var attempt = 0; attempt < 5; attempt++) {
      final ref = _db.collection(collection).doc(code);
      final existing = await ref.get();
      if (!existing.exists) {
        final now = DateTime.now();
        await ref.set({
          'code': code,
          'familyId': familyId,
          'role': role.wireName,
          'createdByAuthUid': createdByAuthUid,
          'createdAt': now.millisecondsSinceEpoch,
          'expiresAt': now.add(ttl).millisecondsSinceEpoch,
          'revoked': false,
        });
        return code;
      }
      code = InviteCode.generate();
    }
    throw StateError('Не удалось сгенерировать уникальный код приглашения');
  }

  @override
  Future<InviteInfo?> find(String code) async {
    final snapshot = await _db.collection(collection).doc(code).get();
    final data = snapshot.data();
    if (data == null) return null;
    return InviteInfo.fromJson(code, data);
  }
}
