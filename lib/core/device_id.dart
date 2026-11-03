import 'dart:async';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/utils/ids.dart';

/// Ключ локального идентификатора устройства в боксе `app_state`.
const String deviceIdStorageKey = 'device_id';

/// Идентификатор этого устройства.
///
/// Нужен, чтобы хранить FCM-токен в `families/{fid}/devices/{deviceId}` и не
/// отправлять уведомление тому, кто сам внёс правку. Значение стабильно, пока
/// живы данные приложения; после переустановки создаётся новое.
String localDeviceId() {
  final storage = MediaStorage.instance;
  final stored = storage.getString(deviceIdStorageKey);
  if (stored != null && stored.isNotEmpty) return stored;

  final created = newUserId();
  unawaited(storage.putString(deviceIdStorageKey, created));
  return created;
}
