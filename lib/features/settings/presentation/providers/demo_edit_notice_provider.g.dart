// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_edit_notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Подсказывает, что демо-архив хранится только на устройстве.
///
/// Пока семья не создана и аккаунт не заведён, правки никуда не уезжают:
/// приложение об этом честно сообщает — один раз диалогом и постоянной меткой
/// в шапке, пока архив не окажется в облаке.

@ProviderFor(DemoEditNoticeNotifier)
final demoEditNoticeProvider = DemoEditNoticeNotifierProvider._();

/// Подсказывает, что демо-архив хранится только на устройстве.
///
/// Пока семья не создана и аккаунт не заведён, правки никуда не уезжают:
/// приложение об этом честно сообщает — один раз диалогом и постоянной меткой
/// в шапке, пока архив не окажется в облаке.
final class DemoEditNoticeNotifierProvider
    extends $NotifierProvider<DemoEditNoticeNotifier, DemoEditNoticeState> {
  /// Подсказывает, что демо-архив хранится только на устройстве.
  ///
  /// Пока семья не создана и аккаунт не заведён, правки никуда не уезжают:
  /// приложение об этом честно сообщает — один раз диалогом и постоянной меткой
  /// в шапке, пока архив не окажется в облаке.
  DemoEditNoticeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'demoEditNoticeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$demoEditNoticeNotifierHash();

  @$internal
  @override
  DemoEditNoticeNotifier create() => DemoEditNoticeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoEditNoticeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoEditNoticeState>(value),
    );
  }
}

String _$demoEditNoticeNotifierHash() =>
    r'b942935324c5c33a44a1ac5c30883fcf3d4d612b';

/// Подсказывает, что демо-архив хранится только на устройстве.
///
/// Пока семья не создана и аккаунт не заведён, правки никуда не уезжают:
/// приложение об этом честно сообщает — один раз диалогом и постоянной меткой
/// в шапке, пока архив не окажется в облаке.

abstract class _$DemoEditNoticeNotifier extends $Notifier<DemoEditNoticeState> {
  DemoEditNoticeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DemoEditNoticeState, DemoEditNoticeState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DemoEditNoticeState, DemoEditNoticeState>,
        DemoEditNoticeState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
