import 'package:ourtree_app/core/utils/json_reader.dart';

/// Одноразовая ссылка для гостевого доступа (`GuestLink`).
class GuestLink {
  const GuestLink({
    required this.id,
    required this.label,
    required this.expiresAt,
    this.createdAt = 0,
    this.revoked = false,
  });

  final String id;

  /// Подпись, по которой админ узнаёт получателя ссылки.
  final String label;

  /// Время создания в миллисекундах с начала эпохи.
  final int createdAt;

  /// Время истечения в миллисекундах с начала эпохи.
  final int expiresAt;

  /// Ссылку отозвали вручную — она не действует даже до истечения.
  final bool revoked;

  DateTime get createdAtDate => DateTime.fromMillisecondsSinceEpoch(createdAt);

  DateTime get expiresAtDate => DateTime.fromMillisecondsSinceEpoch(expiresAt);

  /// `true`, если [moment] уже наступил после срока действия.
  bool isExpiredAt(DateTime moment) => !moment.isBefore(expiresAtDate);

  /// `true`, если ссылка ещё может пустить гостя в альбом.
  bool isActiveAt(DateTime moment) => !revoked && !isExpiredAt(moment);

  factory GuestLink.fromJson(Map<String, dynamic> json) => GuestLink(
        id: readString(json['id']),
        label: readString(json['label']),
        createdAt: readInt(json['createdAt']) ?? 0,
        expiresAt: readInt(json['expiresAt']) ?? 0,
        revoked: readBool(json['revoked']) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'createdAt': createdAt,
        'expiresAt': expiresAt,
        'revoked': revoked,
      };

  GuestLink copyWith({
    String? id,
    String? label,
    int? createdAt,
    int? expiresAt,
    bool? revoked,
  }) =>
      GuestLink(
        id: id ?? this.id,
        label: label ?? this.label,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        revoked: revoked ?? this.revoked,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestLink &&
          id == other.id &&
          label == other.label &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt &&
          revoked == other.revoked;

  @override
  int get hashCode => Object.hash(id, label, createdAt, expiresAt, revoked);
}

/// Данные для выпуска гостевой ссылки (`GuestLinkInput`).
class GuestLinkInput {
  const GuestLinkInput({
    required this.label,
    required this.days,
  });

  final String label;

  /// Срок жизни ссылки в днях.
  final int days;

  Map<String, dynamic> toJson() => {
        'label': label,
        'days': days,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestLinkInput && label == other.label && days == other.days;

  @override
  int get hashCode => Object.hash(label, days);
}

/// Созданная ссылка вместе с секретным токеном.
///
/// Сервер хранит только хеш токена и возвращает сам токен ровно один раз —
/// его нужно сразу передать получателю.
class CreatedGuestLink {
  const CreatedGuestLink({
    required this.link,
    required this.token,
  });

  final GuestLink link;
  final String token;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedGuestLink &&
          link == other.link &&
          token == other.token;

  @override
  int get hashCode => Object.hash(link, token);
}
