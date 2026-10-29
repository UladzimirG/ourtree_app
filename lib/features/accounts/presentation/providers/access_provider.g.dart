// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Архив, отфильтрованный по правам текущего пользователя.
///
/// Локальный владелец устройства (`account == null`) и администраторы видят
/// всё. Редакторы и наблюдатели получают только разрешённых участников и
/// события, не скрытые через `hiddenFrom`.

@ProviderFor(visibleFamily)
final visibleFamilyProvider = VisibleFamilyProvider._();

/// Архив, отфильтрованный по правам текущего пользователя.
///
/// Локальный владелец устройства (`account == null`) и администраторы видят
/// всё. Редакторы и наблюдатели получают только разрешённых участников и
/// события, не скрытые через `hiddenFrom`.

final class VisibleFamilyProvider
    extends $FunctionalProvider<FamilyData?, FamilyData?, FamilyData?>
    with $Provider<FamilyData?> {
  /// Архив, отфильтрованный по правам текущего пользователя.
  ///
  /// Локальный владелец устройства (`account == null`) и администраторы видят
  /// всё. Редакторы и наблюдатели получают только разрешённых участников и
  /// события, не скрытые через `hiddenFrom`.
  VisibleFamilyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'visibleFamilyProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$visibleFamilyHash();

  @$internal
  @override
  $ProviderElement<FamilyData?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyData? create(Ref ref) {
    return visibleFamily(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyData?>(value),
    );
  }
}

String _$visibleFamilyHash() => r'9a6a3ef3273f1d20c835a5148a7f4d26cd8d0dd3';
