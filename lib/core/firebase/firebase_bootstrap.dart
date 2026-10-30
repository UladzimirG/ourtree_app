import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ourtree_app/firebase_options.dart';

/// Инициализация Firebase: Auth, Firestore, Storage и App Check.
///
/// Приложение офлайн-первое: локальные данные в Hive доступны всегда, поэтому
/// сбой инициализации Firebase не должен блокировать запуск — ошибка только
/// запоминается в [lastError] и логируется.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static Object? _lastError;

  static bool get isInitialized => _initialized;

  static Object? get lastError => _lastError;

  /// App Check включается только после настройки провайдеров в консоли:
  /// `flutter run --dart-define=APP_CHECK_ENABLED=true`.
  static const bool appCheckEnabled =
      bool.fromEnvironment('APP_CHECK_ENABLED');

  /// reCAPTCHA v3 site key для web/windows:
  /// `--dart-define=APP_CHECK_WEB_KEY=<key>`.
  static const String appCheckWebKey =
      String.fromEnvironment('APP_CHECK_WEB_KEY');

  /// Debug-токен Windows обязателен: десктопный C++ SDK его не генерирует.
  /// `--dart-define=APP_CHECK_WINDOWS_TOKEN=<token>`.
  static const String appCheckWindowsToken =
      String.fromEnvironment('APP_CHECK_WINDOWS_TOKEN');

  /// Инициализирует Firebase один раз за запуск приложения.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _configureFirestore();
      await _configureAppCheck();
      _initialized = true;
    } catch (error, stackTrace) {
      _lastError = error;
      debugPrint('Firebase не инициализирован: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Включает офлайн-кэш Firestore там, где он поддерживается плагином.
  ///
  /// Windows/Linux работают через C++ SDK без локального кэша — для них
  /// кэширование делает наш собственный слой (Hive + outbox).
  static void _configureFirestore() {
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        break;
    }
  }

  /// Активирует App Check. Пока enforcement в консоли выключен, это только
  /// добавляет заголовок к запросам, поэтому включаем осознанно.
  static Future<void> _configureAppCheck() async {
    if (!appCheckEnabled) return;

    try {
      if (kIsWeb) {
        if (appCheckWebKey.isEmpty) return;
        await FirebaseAppCheck.instance.activate(
          providerWeb: ReCaptchaV3Provider(appCheckWebKey),
        );
        return;
      }

      if (defaultTargetPlatform == TargetPlatform.windows) {
        if (appCheckWindowsToken.isEmpty) return;
        await FirebaseAppCheck.instance.activate(
          providerWindows: WindowsDebugProvider(
            debugToken: appCheckWindowsToken,
          ),
        );
        return;
      }

      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestProvider(),
      );
    } catch (error) {
      // App Check не должен мешать работе приложения: enforcement — в консоли.
      debugPrint('App Check не активирован: $error');
    }
  }
}
