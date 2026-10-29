// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Выбранный язык интерфейса.
///
/// `null` означает «следовать языку системы»: тогда `MaterialApp` получает
/// `locale: null` и Flutter сам выбирает первый подходящий из
/// `AppLocalizations.supportedLocales`.
///
/// Выбор живёт в Hive, поэтому переживает перезапуск приложения и
/// восстанавливается до первого кадра — без «мигания» языка.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Выбранный язык интерфейса.
///
/// `null` означает «следовать языку системы»: тогда `MaterialApp` получает
/// `locale: null` и Flutter сам выбирает первый подходящий из
/// `AppLocalizations.supportedLocales`.
///
/// Выбор живёт в Hive, поэтому переживает перезапуск приложения и
/// восстанавливается до первого кадра — без «мигания» языка.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale?> {
  /// Выбранный язык интерфейса.
  ///
  /// `null` означает «следовать языку системы»: тогда `MaterialApp` получает
  /// `locale: null` и Flutter сам выбирает первый подходящий из
  /// `AppLocalizations.supportedLocales`.
  ///
  /// Выбор живёт в Hive, поэтому переживает перезапуск приложения и
  /// восстанавливается до первого кадра — без «мигания» языка.
  LocaleControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeControllerHash() => r'b585a3ba3ab978811907653d1354182c35fab351';

/// Выбранный язык интерфейса.
///
/// `null` означает «следовать языку системы»: тогда `MaterialApp` получает
/// `locale: null` и Flutter сам выбирает первый подходящий из
/// `AppLocalizations.supportedLocales`.
///
/// Выбор живёт в Hive, поэтому переживает перезапуск приложения и
/// восстанавливается до первого кадра — без «мигания» языка.

abstract class _$LocaleController extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Locale?, Locale?>, Locale?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Итоговый язык интерфейса: выбранный вручную или разрешённый из системы.
///
/// Именно его используют провайдеры данных, чтобы выбрать демо-архив и ключ
/// хранения. Благодаря этому вариант «как в системе» работает и для контента,
/// а не только для подписей интерфейса.

@ProviderFor(appLocale)
final appLocaleProvider = AppLocaleProvider._();

/// Итоговый язык интерфейса: выбранный вручную или разрешённый из системы.
///
/// Именно его используют провайдеры данных, чтобы выбрать демо-архив и ключ
/// хранения. Благодаря этому вариант «как в системе» работает и для контента,
/// а не только для подписей интерфейса.

final class AppLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale> with $Provider<Locale> {
  /// Итоговый язык интерфейса: выбранный вручную или разрешённый из системы.
  ///
  /// Именно его используют провайдеры данных, чтобы выбрать демо-архив и ключ
  /// хранения. Благодаря этому вариант «как в системе» работает и для контента,
  /// а не только для подписей интерфейса.
  AppLocaleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appLocaleProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return appLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$appLocaleHash() => r'f65b4bc606579c7a988be54923c5b2b33d2d7ba2';
