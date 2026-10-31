import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Путь объекта в Storage: `families/{familyId}/media/{assetId}/{fileName}`.
String mediaStoragePath({
  required String familyId,
  required String assetId,
  required String fileName,
}) =>
    'families/$familyId/media/$assetId/$fileName';

/// Результат загрузки файла в облако.
class CloudUploadResult {
  const CloudUploadResult({
    required this.storagePath,
    required this.downloadUrl,
  });

  final String storagePath;
  final String downloadUrl;
}

/// Загрузка/удаление медиа в Firebase Storage.
abstract class CloudMediaStore {
  Future<CloudUploadResult> upload({
    required String familyId,
    required String assetId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    void Function(double progress)? onProgress,
  });

  Future<void> delete(String storagePath);

  Future<String> downloadUrl(String storagePath);
}

/// Реализация на Firebase Storage.
class FirebaseCloudMediaStore implements CloudMediaStore {
  FirebaseCloudMediaStore({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<CloudUploadResult> upload({
    required String familyId,
    required String assetId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final path = mediaStoragePath(
      familyId: familyId,
      assetId: assetId,
      fileName: fileName,
    );

    // putData работает на всех платформах (включая web), в отличие от putFile.
    final task = _storage.ref(path).putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );

    if (onProgress != null) {
      task.snapshotEvents.listen((snapshot) {
        final total = snapshot.totalBytes;
        if (total > 0) onProgress(snapshot.bytesTransferred / total);
      });
    }

    await task;
    final url = await _storage.ref(path).getDownloadURL();
    return CloudUploadResult(storagePath: path, downloadUrl: url);
  }

  @override
  Future<void> delete(String storagePath) async {
    if (storagePath.isEmpty) return;
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException catch (error) {
      // Файла уже нет — это не ошибка для вызывающей стороны.
      if (error.code == 'object-not-found') return;
      rethrow;
    }
  }

  @override
  Future<String> downloadUrl(String storagePath) =>
      _storage.ref(storagePath).getDownloadURL();
}
