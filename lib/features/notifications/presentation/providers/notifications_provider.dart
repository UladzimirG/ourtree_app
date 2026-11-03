import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ourtree_app/core/device_id.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/domain/models/identity_state.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/notifications/data/device_token_store.dart';
import 'package:ourtree_app/features/notifications/domain/notification_prefs.dart';
import 'package:ourtree_app/features/settings/presentation/providers/locale_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';

/// Публичный VAPID-ключ для web-push.
///
/// Передаётся при сборке: `--dart-define-from-file=dart_defines.json`
/// (`{ "FIREBASE_VAPID_KEY": "B..." }`), в коде не хранится.
const String webPushVapidKey = String.fromEnvironment('FIREBASE_VAPID_KEY');

/// Путь к service worker для push.
///
/// Лежит в отдельной области видимости (`/push/`), чтобы не конфликтовать с
/// `flutter_service_worker.js`, который кэширует приложение.
const String webPushServiceWorkerPath = 'push/firebase-messaging-sw.js';

/// Локальный ключ настроек уведомлений.
const String notificationPrefsStorageKey = 'notification_prefs';

/// Локальный ключ «пользователь включил уведомления».
const String notificationEnabledStorageKey = 'notification_enabled';

/// Хранилище токенов устройств; подменяется в тестах.
@Riverpod(keepAlive: true)
DeviceTokenStore deviceTokenStore(Ref ref) => FirestoreDeviceTokenStore();

/// Состояние разрешения на уведомления.
enum NotificationPermissionState { unknown, granted, denied }

/// Сообщение, пришедшее при открытом приложении.
class ForegroundMessage {
  const ForegroundMessage({this.title = '', this.body = '', this.serial = 0});

  final String title;
  final String body;

  /// Растёт с каждым сообщением: одинаковые тексты всё равно показываем.
  final int serial;
}

/// Состояние уведомлений на этом устройстве.
class NotificationsState {
  const NotificationsState({
    this.permission = NotificationPermissionState.unknown,
    this.prefs = const NotificationPrefs(),
    this.busy = false,
    this.registered = false,
    this.error,
    this.lastMessage,
  });

  final NotificationPermissionState permission;
  final NotificationPrefs prefs;
  final bool busy;

  /// Токен устройства сохранён в семье — пуши будут приходить.
  final bool registered;

  /// Ключ локализации для текста ошибки.
  final String? error;

  final ForegroundMessage? lastMessage;
}

/// Включение уведомлений, токен устройства и настройки.
@Riverpod(keepAlive: true)
class NotificationsController extends _$NotificationsController {
  StreamSubscription<RemoteMessage>? _onMessage;
  StreamSubscription<RemoteMessage>? _onOpened;
  int _serial = 0;

  @override
  NotificationsState build() {
    ref.onDispose(() {
      _onMessage?.cancel();
      _onOpened?.cancel();
    });

    ref.listen(activeFamilyControllerProvider, (previous, next) {
      final family = next.value;
      if (family == null) return;
      if (previous?.value?.id == family.id) return;
      // Семья подключилась позже — регистрируем токен уже в ней.
      unawaited(_registerIfEnabled());
    });

    _listenForMessages();
    // Уже включённые уведомления: обновляем токен при запуске (он мог смениться).
    unawaited(_registerIfEnabled());

    return NotificationsState(
      prefs: _loadPrefs(),
      registered:
          MediaStorage.instance.getString(notificationEnabledStorageKey) !=
              null,
    );
  }

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  void _listenForMessages() {
    try {
      _onMessage = FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? '';
        final body = message.notification?.body ?? '';
        if (title.isEmpty && body.isEmpty) return;
        _serial++;
        state = NotificationsState(
          permission: state.permission,
          prefs: state.prefs,
          registered: state.registered,
          error: state.error,
          lastMessage: ForegroundMessage(
            title: title,
            body: body,
            serial: _serial,
          ),
        );
      });
      _onOpened = FirebaseMessaging.onMessageOpenedApp.listen((_) {});
    } catch (error) {
      // Без service worker (http или старый браузер) подписка недоступна —
      // уведомления просто не показываются.
      debugPrint('Уведомления: подписка недоступна: $error');
    }
  }

  NotificationPrefs _loadPrefs() {
    final raw = MediaStorage.instance.getString(notificationPrefsStorageKey);
    if (raw == null || raw.trim().isEmpty) return const NotificationPrefs();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const NotificationPrefs();
      return NotificationPrefs.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return const NotificationPrefs();
    }
  }

  /// Читает текущее разрешение и, если оно выдано, обновляет токен.
  Future<void> refresh() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      final granted = _isGranted(settings.authorizationStatus);
      state = _with(
        permission: granted
            ? NotificationPermissionState.granted
            : NotificationPermissionState.denied,
      );
      if (granted) await _registerIfEnabled();
    } catch (error) {
      debugPrint('Уведомления: не удалось прочитать разрешение: $error');
    }
  }

  /// Запрашивает разрешение и регистрирует токен устройства.
  ///
  /// На iOS и в вебе запрос обязан идти из жеста пользователя — поэтому метод
  /// вызывается только кнопкой в интерфейсе.
  Future<void> enable() async {
    if (state.busy) return;
    state = _with(busy: true, clearError: true);

    try {
      if (kIsWeb && webPushVapidKey.isEmpty) {
        state = _with(busy: false, error: 'notificationsFailedNoKey');
        return;
      }

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (!_isGranted(settings.authorizationStatus)) {
        state = _with(
          busy: false,
          permission: NotificationPermissionState.denied,
          error: 'notificationsFailedPermission',
        );
        return;
      }

      await MediaStorage.instance.putString(notificationEnabledStorageKey, '1');
      final token = await _token();
      if (token == null || token.isEmpty) {
        state = _with(busy: false, error: 'notificationsFailedToken');
        return;
      }

      final saved = await _saveToken(token);
      state = _with(
        busy: false,
        permission: NotificationPermissionState.granted,
        registered: saved,
        error: saved ? null : 'notificationsFailedNoFamily',
      );
    } catch (error) {
      debugPrint('Уведомления: включить не удалось: $error');
      state = _with(busy: false, error: 'notificationsFailed');
    }
  }

  /// Отписывается от уведомлений на этом устройстве.
  Future<void> disable() async {
    if (state.busy) return;
    state = _with(busy: true, clearError: true);

    try {
      final familyId = ref.read(activeFamilyControllerProvider).value?.id;
      if (familyId != null) {
        try {
          await ref.read(deviceTokenStoreProvider).remove(
                familyId: familyId,
                deviceId: localDeviceId(),
              );
        } catch (error) {
          debugPrint('Уведомления: не удалось удалить токен: $error');
        }
      }
      // ignore: deprecated_member_use
      await _messaging.deleteToken();
      await MediaStorage.instance.removeString(notificationEnabledStorageKey);
      state = _with(busy: false, registered: false);
    } catch (error) {
      debugPrint('Уведомления: отключить не удалось: $error');
      state = _with(busy: false, error: 'notificationsFailed');
    }
  }

  /// Сохраняет настройки локально и в документе устройства.
  Future<void> updatePrefs(NotificationPrefs prefs) async {
    state = _with(prefs: prefs);
    await MediaStorage.instance.putString(
      notificationPrefsStorageKey,
      jsonEncode(prefs.toJson()),
    );

    final familyId = ref.read(activeFamilyControllerProvider).value?.id;
    if (familyId == null || !state.registered) return;
    try {
      await ref.read(deviceTokenStoreProvider).savePrefs(
            familyId: familyId,
            deviceId: localDeviceId(),
            prefs: prefs,
          );
    } catch (error) {
      debugPrint('Уведомления: настройки не сохранились в облако: $error');
    }
  }

  /// Повторная регистрация (например, после смены разрешения в настройках ОС).
  Future<void> retry() => _registerIfEnabled();

  Future<void> _registerIfEnabled() async {
    if (MediaStorage.instance.getString(notificationEnabledStorageKey) ==
        null) {
      return;
    }
    try {
      final settings = await _messaging.getNotificationSettings();
      if (!_isGranted(settings.authorizationStatus)) return;
      final token = await _token();
      if (token == null || token.isEmpty) return;
      final saved = await _saveToken(token);
      state = _with(
        permission: NotificationPermissionState.granted,
        registered: saved,
      );
    } catch (error) {
      debugPrint('Уведомления: регистрация не удалась: $error');
    }
  }

  /// FCM-токен; на вебе — со своим service worker вне scope Flutter.
  ///
  /// `getToken` помечен deprecated в пользу `register()`/`onRegistered`, но
  /// новый API отдаёт FID, а Admin SDK (`sendEachForMulticast`) работает с
  /// классическими registration-токенами — поэтому оставляем `getToken`.
  ///
  /// На вебе первый вызов может прийтись на момент, когда service worker ещё
  /// устанавливается, поэтому повторяем несколько раз.
  Future<String?> _token() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        // ignore: deprecated_member_use
        final token = await _messaging.getToken(
          vapidKey:
              kIsWeb && webPushVapidKey.isNotEmpty ? webPushVapidKey : null,
          serviceWorkerScriptPath: kIsWeb ? webPushServiceWorkerPath : null,
        );
        if (token != null && token.isNotEmpty) return token;
      } catch (error) {
        debugPrint(
            'Уведомления: токен не получен (попытка ${attempt + 1}): $error');
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  /// Сохраняет токен в документе устройства активной семьи.
  Future<bool> _saveToken(String token) async {
    final family = await _family();
    final identity = await _identity();
    if (family == null || identity == null || !identity.isSignedIn) {
      return false;
    }

    await ref.read(deviceTokenStoreProvider).save(
          familyId: family.id,
          deviceId: localDeviceId(),
          token: token,
          platform: _platformName(),
          locale: ref.read(appLocaleProvider).languageCode,
          timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
          prefs: state.prefs,
          authUid: identity.authUid,
          userId: identity.userId,
        );
    return true;
  }

  Future<FamilyModel?> _family() async {
    final current = ref.read(activeFamilyControllerProvider).value;
    if (current != null) return current;
    try {
      return await ref.read(activeFamilyControllerProvider.future);
    } catch (_) {
      return null;
    }
  }

  Future<IdentityState?> _identity() async {
    final current = ref.read(identityControllerProvider).value;
    if (current != null) return current;
    try {
      return await ref.read(identityControllerProvider.future);
    } catch (_) {
      return null;
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  bool _isGranted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  NotificationsState _with({
    NotificationPermissionState? permission,
    NotificationPrefs? prefs,
    bool? busy,
    bool? registered,
    String? error,
    bool clearError = false,
  }) =>
      NotificationsState(
        permission: permission ?? state.permission,
        prefs: prefs ?? state.prefs,
        busy: busy ?? state.busy,
        registered: registered ?? state.registered,
        error: clearError ? null : (error ?? state.error),
        lastMessage: state.lastMessage,
      );
}
