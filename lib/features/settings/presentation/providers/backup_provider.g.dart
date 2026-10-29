// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Локальные резервные копии семейного архива.
///
/// Снимок — это полный JSON архива плюс копии всех локальных файлов медиатеки
/// (Hive и ассетов). Поэтому после восстановления фотографии доступны, даже
/// если оригиналы были удалены.

@ProviderFor(BackupsNotifier)
final backupsProvider = BackupsNotifierProvider._();

/// Локальные резервные копии семейного архива.
///
/// Снимок — это полный JSON архива плюс копии всех локальных файлов медиатеки
/// (Hive и ассетов). Поэтому после восстановления фотографии доступны, даже
/// если оригиналы были удалены.
final class BackupsNotifierProvider
    extends $AsyncNotifierProvider<BackupsNotifier, BackupList> {
  /// Локальные резервные копии семейного архива.
  ///
  /// Снимок — это полный JSON архива плюс копии всех локальных файлов медиатеки
  /// (Hive и ассетов). Поэтому после восстановления фотографии доступны, даже
  /// если оригиналы были удалены.
  BackupsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backupsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backupsNotifierHash();

  @$internal
  @override
  BackupsNotifier create() => BackupsNotifier();
}

String _$backupsNotifierHash() => r'2144c67229d1fd4fd4e5d5c964ab9e8ebeec2592';

/// Локальные резервные копии семейного архива.
///
/// Снимок — это полный JSON архива плюс копии всех локальных файлов медиатеки
/// (Hive и ассетов). Поэтому после восстановления фотографии доступны, даже
/// если оригиналы были удалены.

abstract class _$BackupsNotifier extends $AsyncNotifier<BackupList> {
  FutureOr<BackupList> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BackupList>, BackupList>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<BackupList>, BackupList>,
        AsyncValue<BackupList>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
