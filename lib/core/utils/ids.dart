import 'dart:math';

import 'package:uuid/uuid.dart';

/// Генерация идентификаторов.
///
/// Все облачные сущности используют UUID v4: он не содержит времени создания
/// (в отличие от прежних `account-<microsecondsSinceEpoch>`) и не позволяет
/// угадать соседний идентификатор.
const Uuid _uuid = Uuid();

String newUserId() => _uuid.v4();

String newFamilyId() => _uuid.v4();

String newPersonId() => _uuid.v4();

String newEventId() => _uuid.v4();

String newMediaAssetId() => _uuid.v4();

String newInviteId() => _uuid.v4();

String newPurchaseId() => _uuid.v4();

/// Алфавит без похожих символов (0/O, 1/I/L) — код диктуют голосом.
const String _inviteAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/// Код приглашения в семью: 8 символов, ~40 бит энтропии.
String newInviteCode([int length = 8]) {
  final random = Random.secure();
  return String.fromCharCodes(
    List<int>.generate(
      length,
      (_) => _inviteAlphabet.codeUnitAt(random.nextInt(_inviteAlphabet.length)),
    ),
  );
}
