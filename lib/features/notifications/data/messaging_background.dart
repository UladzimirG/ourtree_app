import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ourtree_app/firebase_options.dart';

/// Обработчик фоновых сообщений FCM (Android/iOS).
///
/// Сервер присылает `notification`-payload, поэтому системное уведомление
/// показывает сам FCM. Обработчик нужен, чтобы фоновый изолят не падал при
/// инициализации и чтобы данные сообщения попадали в лог для диагностики.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    // Приложение могло уже инициализировать Firebase — это не ошибка.
    debugPrint('Push (background): Firebase уже инициализирован: $error');
  }
  debugPrint('Push (background): ${message.messageId} ${message.data}');
}
