import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_video_player.dart';
import 'video_converter_stub.dart'
    if (dart.library.io) 'video_converter_io.dart'
    if (dart.library.html) 'video_converter_web.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Общая медиатека семьи.
class MediaLibraryPanel extends ConsumerStatefulWidget {
  const MediaLibraryPanel({super.key});

  @override
  ConsumerState<MediaLibraryPanel> createState() => _MediaLibraryPanelState();
}

class _MediaLibraryPanelState extends ConsumerState<MediaLibraryPanel> {
  bool _busy = false;
  String? _convertingId;

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    String? error;

    try {
      final files = await FilePicker.pickFiles(type: FileType.media);
      for (final file in files) {
        final size = file.lengthSync() ?? await file.length() ?? 0;
        if (size > 20 * 1024 * 1024) {
          error = l10n.mediaUploadTooLarge(file.name);
          continue;
        }
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          error = l10n.mediaUploadEmpty;
          continue;
        }
        final storedId = await MediaStorage.instance.saveBytes(
          bytes,
          name: file.name,
        );
        ref.read(familyDataProvider.notifier).upsertMediaAsset(
              MediaAsset(
                id: 'asset-$storedId',
                source: 'hive://$storedId',
                type: _mediaType(file.name),
                name: file.name,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                size: bytes.length,
              ),
            );
      }
    } catch (_) {
      error = l10n.mediaUploadFailed;
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _addByLink() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final source = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.mediaLibraryAddLink),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: settingsInputDecoration(hint: l10n.mediaSourceField),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.mediaAdd),
          ),
        ],
      ),
    );
    controller.dispose();
    if (source == null || source.isEmpty) return;

    ref.read(familyDataProvider.notifier).upsertMediaAsset(
          MediaAsset(
            id: 'asset-${DateTime.now().microsecondsSinceEpoch}',
            source: source,
            type: _mediaType(source),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> _convert(MediaAsset asset, AppLocalizations l10n) async {
    final storedId = asset.storedId;
    if (storedId == null || !videoConversionSupported) return;
    final bytes = await MediaStorage.instance.loadBytes(storedId);
    if (bytes == null || !mounted) return;

    setState(() => _convertingId = asset.id);
    final result = await convertVideoToWebm(bytes, name: asset.name);
    if (!mounted) return;
    if (result == null) {
      setState(() => _convertingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.videoConvertFailed)),
      );
      return;
    }

    final newStoredId = await MediaStorage.instance.saveBytes(
      result.bytes,
      name: 'converted.${result.extension}',
    );
    final base = (asset.name ?? 'video').split('.').first;
    final updated = asset.copyWith(
      source: 'hive://$newStoredId',
      name: () =>
          '${base.isEmpty ? 'video' : base}.${result.extension}',
      type: MediaType.video,
      size: () => result.bytes.length,
    );
    ref.read(familyDataProvider.notifier).upsertMediaAsset(updated);
    await MediaStorage.instance.deleteBytes(storedId);
    if (!mounted) return;
    setState(() => _convertingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.videoConverted)),
    );
  }

  Future<void> _delete(MediaAsset asset, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.mediaDeleteTitle),
        content: Text(l10n.mediaDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.mediaDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final storedId = asset.storedId;
    if (storedId != null) {
      await MediaStorage.instance.deleteBytes(storedId);
    }
    ref.read(familyDataProvider.notifier).removeMediaAsset(asset.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mediaDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final family = ref.watch(familyDataProvider).valueOrNull;
    final assets = family?.mediaLibrary ?? const <MediaAsset>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(l10n.settingsMediaHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _upload,
              icon: Icon(_busy ? Icons.hourglass_top : Icons.upload_file),
              label: Text(
                _busy ? l10n.mediaUploading : l10n.mediaLibraryUpload,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addByLink,
              icon: const Icon(Icons.add_link),
              label: Text(l10n.mediaLibraryAddLink),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l10n.mediaLibrarySize(
            assets.length,
            _formatSize(
              assets.fold<int>(0, (sum, asset) => sum + (asset.size ?? 0)),
              l10n,
            ),
          ),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        if (assets.isEmpty)
          Text(l10n.mediaLibraryEmpty, style: theme.textTheme.bodyLarge)
        else if (family != null)
          for (final asset in assets) ...[
            _MediaAssetCard(
              key: ValueKey(asset.id),
              asset: asset,
              family: family,
              l10n: l10n,
              converting: _convertingId == asset.id,
              onConvert: () => _convert(asset, l10n),
              onDelete: () => _delete(asset, l10n),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MediaAssetCard extends ConsumerWidget {
  const _MediaAssetCard({
    super.key,
    required this.asset,
    required this.family,
    required this.l10n,
    required this.converting,
    required this.onConvert,
    required this.onDelete,
  });

  final MediaAsset asset;
  final FamilyData family;
  final AppLocalizations l10n;
  final bool converting;
  final VoidCallback onConvert;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.kraftWash,
      elevation: 0,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: SizedBox(
          width: 52,
          height: 52,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: asset.isVideo
                ? const ColoredBox(
                    color: AppColors.paper,
                    child: Icon(Icons.videocam_outlined),
                  )
                : FamilyPhoto(
                    source: asset.source,
                    fallback: const ColoredBox(
                      color: AppColors.paper,
                      child: Icon(Icons.image_outlined),
                    ),
                  ),
          ),
        ),
        title: Text(
          asset.name?.trim().isNotEmpty == true
              ? asset.name!
              : l10n.mediaLibraryTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            asset.isVideo ? l10n.mediaTypeVideo : l10n.mediaTypeImage,
            if (asset.isStored) l10n.mediaStoredLocally,
            if (asset.size != null) _formatSize(asset.size!, l10n),
          ].join(' · '),
          style: theme.textTheme.bodySmall,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          if (asset.isVideo && asset.source.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MediaVideoPlayer(
                source: asset.source,
                name: asset.name,
              ),
            ),
          SettingsTextField(
            label: l10n.mediaAssetName,
            initialValue: asset.name ?? '',
            onChanged: (value) => ref
                .read(familyDataProvider.notifier)
                .upsertMediaAsset(
                  asset.copyWith(
                    name: () => value.trim().isEmpty ? null : value,
                  ),
                ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.mediaAssetType.toUpperCase(),
                  style: settingsCaptionStyle(theme),
                ),
              ),
              DropdownButton<MediaType>(
                value: asset.type,
                items: [
                  DropdownMenuItem(
                    value: MediaType.image,
                    child: Text(l10n.mediaTypeImage),
                  ),
                  DropdownMenuItem(
                    value: MediaType.video,
                    child: Text(l10n.mediaTypeVideo),
                  ),
                ],
                onChanged: (type) {
                  if (type != null) {
                    ref.read(familyDataProvider.notifier).upsertMediaAsset(
                          asset.copyWith(type: type),
                        );
                  }
                },
              ),
            ],
          ),
          if (videoConversionSupported &&
              asset.isVideo &&
              asset.storedId != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: converting ? null : onConvert,
                    icon: Icon(
                      converting ? Icons.hourglass_top : Icons.sync,
                    ),
                    label: Text(
                      converting ? l10n.videoConverting : l10n.videoConvert,
                    ),
                  ),
                  Text(
                    l10n.videoConvertHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ..._peopleSection(context, ref),
          ..._usageSection(context),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.terracotta,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.mediaDelete),
            ),
          ),
        ],
      ),
    );
  }

  bool _matches(FamilyMedia media) =>
      media.mediaId == asset.id || media.source == asset.source;

  List<String> _usages() {
    final result = <String>[];
    if (family.familyPhoto == asset.source) {
      result.add(l10n.mediaUsageFamilyPhoto);
    }
    for (final member in family.members) {
      final name = member.name.trim().isEmpty ? '—' : member.name;
      if (member.photo == asset.source) {
        result.add(l10n.mediaUsageAvatar(name));
      }
      if (member.birthdayMedia.any(_matches)) {
        result.add(l10n.mediaUsageBirthday(name));
      }
      final inGallery = member.gallery.any(
        (shot) => shot.photo == asset.source || shot.media.any(_matches),
      );
      if (inGallery) result.add(l10n.mediaUsageGallery(name));
    }
    for (final event in family.timelineEvents) {
      final name = event.title.trim().isEmpty ? '—' : event.title;
      final inEvent = event.photo == asset.source || event.media.any(_matches);
      if (inEvent) result.add(l10n.mediaUsageEvent(name));
    }
    return result;
  }

  List<Widget> _peopleSection(BuildContext context, WidgetRef ref) {
    return [
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l10n.mediaPeopleField.toUpperCase(),
          style: settingsCaptionStyle(Theme.of(context)),
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final member in family.members)
            FilterChip(
              label: Text(member.name.trim().isEmpty ? '—' : member.name),
              selected: asset.people.any((person) => person.id == member.id),
              onSelected: (selected) {
                final next = selected
                    ? [
                        ...asset.people.where((p) => p.id != member.id),
                        GalleryPerson(id: member.id),
                      ]
                    : asset.people
                        .where((p) => p.id != member.id)
                        .toList(growable: false);
                ref.read(familyDataProvider.notifier).upsertMediaAsset(
                      asset.copyWith(people: next),
                    );
              },
            ),
        ],
      ),
      for (final member in family.members)
        if (asset.people.any((person) => person.id == member.id))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              key: ValueKey('${asset.id}-caption-${member.id}'),
              initialValue: asset.people
                      .firstWhere((person) => person.id == member.id)
                      .caption ??
                  '',
              decoration: settingsInputDecoration(
                hint: l10n.mediaPersonCaption(
                  member.name.trim().isEmpty ? '—' : member.name,
                ),
              ),
              onChanged: (value) {
                final people = [
                  for (final person in asset.people)
                    if (person.id == member.id)
                      person.copyWith(
                        caption: () =>
                            value.trim().isEmpty ? null : value,
                      )
                    else
                      person,
                ];
                ref.read(familyDataProvider.notifier).upsertMediaAsset(
                      asset.copyWith(people: people),
                    );
              },
            ),
          ),
    ];
  }

  List<Widget> _usageSection(BuildContext context) {
    final usages = _usages();
    return [
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l10n.mediaUsageTitle.toUpperCase(),
          style: settingsCaptionStyle(Theme.of(context)),
        ),
      ),
      const SizedBox(height: 4),
      if (usages.isEmpty)
        Text(l10n.mediaUsageNone, style: Theme.of(context).textTheme.bodySmall)
      else
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final usage in usages)
              Chip(
                label: Text(usage),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
    ];
  }
}

bool _isVideoName(String name) {
  final lower = name.toLowerCase();
  return ['.mp4', '.webm', '.mov', '.m4v', '.avi', '.mkv']
      .any(lower.endsWith);
}

MediaType _mediaType(String name) =>
    _isVideoName(name) ? MediaType.video : MediaType.image;

String _formatSize(int bytes, AppLocalizations l10n) {
  if (bytes < 1024) return l10n.backupSizeBytes(bytes);
  if (bytes < 1024 * 1024) {
    return l10n.backupSizeKb((bytes / 1024).toStringAsFixed(1));
  }
  return l10n.backupSizeMb((bytes / (1024 * 1024)).toStringAsFixed(1));
}
