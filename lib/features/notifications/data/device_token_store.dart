import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourtree_app/features/notifications/domain/notification_prefs.dart';

/// Документ устройства с FCM-токеном: `families/{fid}/devices/{deviceId}`.
///
/// По этим документам Cloud Functions рассылает пуши. Ключ — идентификатор
/// устройства, чтобы одно устройство не плодило записи при каждом запуске.
abstract class DeviceTokenStore {
  Future<void> save({
    required String familyId,
    required String deviceId,
    required String token,
    required String platform,
    required String locale,
    required int timezoneOffsetMinutes,
    required NotificationPrefs prefs,
    required String authUid,
    required String userId,
    String role = 'member',
  });

  Future<void> savePrefs({
    required String familyId,
    required String deviceId,
    required NotificationPrefs prefs,
  });

  Future<void> remove({
    required String familyId,
    required String deviceId,
  });
}

/// Реализация поверх Cloud Firestore.
class FirestoreDeviceTokenStore implements DeviceTokenStore {
  FirestoreDeviceTokenStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String devicesCollection = 'devices';

  DocumentReference<Map<String, dynamic>> _doc(
    String familyId,
    String deviceId,
  ) =>
      _db
          .collection('families')
          .doc(familyId)
          .collection(devicesCollection)
          .doc(deviceId);

  @override
  Future<void> save({
    required String familyId,
    required String deviceId,
    required String token,
    required String platform,
    required String locale,
    required int timezoneOffsetMinutes,
    required NotificationPrefs prefs,
    required String authUid,
    required String userId,
    String role = 'member',
  }) =>
      _doc(familyId, deviceId).set(
        {
          'token': token,
          'platform': platform,
          'locale': locale,
          'timezoneOffsetMinutes': timezoneOffsetMinutes,
          'prefs': prefs.toJson(),
          'authUid': authUid,
          'userId': userId,
          // Роль нужна серверу: «изменения семьи» присылаем только админу.
          'role': role,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );

  @override
  Future<void> savePrefs({
    required String familyId,
    required String deviceId,
    required NotificationPrefs prefs,
  }) =>
      _doc(familyId, deviceId).set(
        {
          'prefs': prefs.toJson(),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );

  @override
  Future<void> remove({
    required String familyId,
    required String deviceId,
  }) =>
      _doc(familyId, deviceId).delete();
}
