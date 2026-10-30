import 'package:ourtree_app/core/utils/json_reader.dart';

/// Откуда пришёл премиум-статус.
enum PremiumSource {
  none('none'),
  revenueCat('revenuecat'),
  telegram('telegram'),
  manual('manual');

  const PremiumSource(this.wireName);

  final String wireName;

  static PremiumSource fromWire(Object? value) {
    for (final source in values) {
      if (source.wireName == value) return source;
    }
    return PremiumSource.none;
  }
}

/// Тип покупки. Сейчас поддерживается только пожизненная.
enum PremiumPlan {
  none('none'),
  lifetime('lifetime');

  const PremiumPlan(this.wireName);

  final String wireName;

  static PremiumPlan fromWire(Object? value) {
    for (final plan in values) {
      if (plan.wireName == value) return plan;
    }
    return PremiumPlan.none;
  }
}

/// Премиум-статус семьи — единственный источник истины для всех устройств.
///
/// Пишется только Cloud Functions (Admin SDK): RevenueCat-вебхуком либо
/// Telegram-вебхуком. Клиент эти поля не обновляет — так правило безопасности
/// остаётся простым, а статус одинаковым на Android, iOS, Windows и Web.
class PremiumStatus {
  const PremiumStatus({
    this.active = false,
    this.plan = PremiumPlan.none,
    this.source = PremiumSource.none,
    this.purchasedAt = 0,
    this.expiresAt,
    this.providerRef,
  });

  const PremiumStatus.inactive()
      : active = false,
        plan = PremiumPlan.none,
        source = PremiumSource.none,
        purchasedAt = 0,
        expiresAt = null,
        providerRef = null;

  final bool active;
  final PremiumPlan plan;
  final PremiumSource source;

  /// Время покупки в миллисекундах эпохи; `0` — неизвестно.
  final int purchasedAt;

  /// `null` для пожизненной покупки.
  final int? expiresAt;

  /// Идентификатор платежа у провайдера (RC event id / telegram charge id).
  final String? providerRef;

  bool get isLifetime => active && plan == PremiumPlan.lifetime;

  /// Активен ли премиум на момент [now] (учитывает возможный срок действия).
  bool isActiveAt(DateTime now) {
    if (!active) return false;
    final until = expiresAt;
    return until == null || until > now.millisecondsSinceEpoch;
  }

  factory PremiumStatus.fromJson(Map<String, dynamic> json) => PremiumStatus(
        active: readBool(json['active']) ?? false,
        plan: PremiumPlan.fromWire(json['plan']),
        source: PremiumSource.fromWire(json['source']),
        purchasedAt: readInt(json['purchasedAt']) ?? 0,
        expiresAt: readInt(json['expiresAt']),
        providerRef: readNullableString(json['providerRef']),
      );

  Map<String, dynamic> toJson() => {
        'active': active,
        'plan': plan.wireName,
        'source': source.wireName,
        if (purchasedAt > 0) 'purchasedAt': purchasedAt,
        if (expiresAt != null) 'expiresAt': expiresAt,
        if (providerRef != null && providerRef!.isNotEmpty)
          'providerRef': providerRef,
      };

  PremiumStatus copyWith({
    bool? active,
    PremiumPlan? plan,
    PremiumSource? source,
    int? purchasedAt,
    int? Function()? expiresAt,
    String? Function()? providerRef,
  }) =>
      PremiumStatus(
        active: active ?? this.active,
        plan: plan ?? this.plan,
        source: source ?? this.source,
        purchasedAt: purchasedAt ?? this.purchasedAt,
        expiresAt: expiresAt == null ? this.expiresAt : expiresAt(),
        providerRef: providerRef == null ? this.providerRef : providerRef(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumStatus &&
          active == other.active &&
          plan == other.plan &&
          source == other.source &&
          purchasedAt == other.purchasedAt &&
          expiresAt == other.expiresAt &&
          providerRef == other.providerRef;

  @override
  int get hashCode =>
      Object.hash(active, plan, source, purchasedAt, expiresAt, providerRef);
}
