import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_upload_preparer.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_video_player.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_viewer.dart';
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
  bool _onlyUnused = false;

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

        // Видео автоматически приводятся к формату текущей платформы.
        final prepared = await prepareMediaUpload(bytes, file.name);
        if (prepared == null) {
          error = l10n.videoConvertFailed;
          continue;
        }
        final mediaBytes = prepared.bytes;
        if (mediaBytes.length > 20 * 1024 * 1024) {
          error = l10n.mediaUploadTooLarge(prepared.name);
          continue;
        }

        final hash = sha256.convert(mediaBytes).toString();
        final existing =
            ref.read(familyDataProvider).valueOrNull?.findDuplicateMedia(
                  hash: hash,
                  name: prepared.name,
                  size: mediaBytes.length,
                );
        if (existing != null) {
          error = l10n.mediaDuplicateFound;
          continue;
        }
        final storedId = await MediaStorage.instance.saveBytes(
          mediaBytes,
          name: prepared.name,
        );
        ref.read(familyDataProvider.notifier).upsertMediaAsset(
              MediaAsset(
                id: 'asset-$storedId',
                source: 'hive://$storedId',
                type: prepared.type,
                name: prepared.name,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                size: mediaBytes.length,
                hash: hash,
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
            type: mediaTypeForName(source),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  void _openViewer(List<MediaAsset> assets, int index) {
    final l10n = AppLocalizations.of(context)!;
    showMediaViewer(
      context,
      items: [
        for (final asset in assets)
          MediaViewerItem(
            source: asset.source,
            type: asset.type,
            name: asset.name,
          ),
      ],
      initialIndex: index,
      eyebrow: l10n.mediaLibraryTitle,
      title: l10n.mediaLibraryTitle,
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

  Future<void> _use(MediaAsset asset, AppLocalizations l10n) async {
    final family = ref.read(familyDataProvider).valueOrNull;
    if (family == null || family.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mediaUseNoMembers)),
      );
      return;
    }
    final selected = {for (final person in asset.people) person.id};
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.mediaUseTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final member in family.members)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: selected.contains(member.id),
                    title: Text(
                      member.name.trim().isEmpty ? '—' : member.name,
                    ),
                    onChanged: (value) => setDialogState(() {
                      if (value == true) {
                        selected.add(member.id);
                      } else {
                        selected.remove(member.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop({...selected}),
              child: Text(l10n.mediaUseApply),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    final people = [
      for (final person in asset.people)
        if (result.contains(person.id)) person,
      for (final id in result)
        if (!asset.people.any((person) => person.id == id))
          GalleryPerson(id: id),
    ];
    ref.read(familyDataProvider.notifier).upsertMediaAsset(
          asset.copyWith(people: people),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mediaUsed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final family = ref.watch(familyDataProvider).valueOrNull;
    final allAssets = family?.mediaLibrary ?? const <MediaAsset>[];
    final unusedCount = family == null
        ? 0
        : allAssets
            .where((asset) => mediaUsageLabels(family, asset, l10n).isEmpty)
            .length;
    final assets = _onlyUnused && family != null
        ? allAssets
            .where((asset) => mediaUsageLabels(family, asset, l10n).isEmpty)
            .toList(growable: false)
        : allAssets;

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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            selected: _onlyUnused,
            label: Text(l10n.mediaOnlyUnused(unusedCount)),
            onSelected: (value) => setState(() => _onlyUnused = value),
          ),
        ),
        const SizedBox(height: 14),
        if (assets.isEmpty)
          Text(l10n.mediaLibraryEmpty, style: theme.textTheme.bodyLarge)
        else if (family != null)
          for (var index = 0; index < assets.length; index++) ...[
            _MediaAssetCard(
              key: ValueKey(assets[index].id),
              asset: assets[index],
              family: family,
              l10n: l10n,
              onOpen: () => _openViewer(assets, index),
              onUse: () => _use(assets[index], l10n),
              onDelete: () => _delete(assets[index], l10n),
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
    required this.onOpen,
    required this.onUse,
    required this.onDelete,
  });

  final MediaAsset asset;
  final FamilyData family;
  final AppLocalizations l10n;
  final VoidCallback onOpen;
  final VoidCallback onUse;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usages = mediaUsageLabels(family, asset, l10n);
    final unused = usages.isEmpty;

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.kraftWash,
      elevation: 0,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpen,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
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
                Positioned(
                  right: 3,
                  bottom: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xAA000000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(
                        Icons.zoom_out_map,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
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
            if (unused) l10n.mediaUnused,
          ].join(' · '),
          style: theme.textTheme.bodySmall,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.zoom_out_map),
              label: Text(l10n.mediaViewerOpen),
            ),
          ),
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
            onChanged: (value) =>
                ref.read(familyDataProvider.notifier).upsertMediaAsset(
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
          ..._peopleSection(context, ref),
          ..._usageSection(context, usages),
          if (unused)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onUse,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(l10n.mediaUseInProfile),
              ),
            ),
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
                dense: true,
              ),
              onChanged: (value) {
                final people = [
                  for (final person in asset.people)
                    if (person.id == member.id)
                      person.copyWith(
                        caption: () => value.trim().isEmpty ? null : value,
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

  List<Widget> _usageSection(
    BuildContext context,
    List<String> usages,
  ) {
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

/// Где используется файл. Пустой список — «мёртвый груз».
List<String> mediaUsageLabels(
  FamilyData family,
  MediaAsset asset,
  AppLocalizations l10n,
) {
  final result = <String>[];
  bool matches(FamilyMedia media) =>
      media.mediaId == asset.id || media.source == asset.source;

  if (family.familyPhoto == asset.source) {
    result.add(l10n.mediaUsageFamilyPhoto);
  }
  for (final member in family.members) {
    final name = member.name.trim().isEmpty ? '—' : member.name;
    if (member.photo == asset.source) {
      result.add(l10n.mediaUsageAvatar(name));
    }
    if (member.birthdayMedia.any(matches)) {
      result.add(l10n.mediaUsageBirthday(name));
    }
    final inGallery = member.gallery.any(
      (shot) => shot.photo == asset.source || shot.media.any(matches),
    );
    if (inGallery) result.add(l10n.mediaUsageGallery(name));
  }
  for (final event in family.timelineEvents) {
    final name = event.title.trim().isEmpty ? '—' : event.title;
    final inEvent = event.photo == asset.source || event.media.any(matches);
    if (inEvent) result.add(l10n.mediaUsageEvent(name));
  }
  for (final person in asset.people) {
    final member = family.memberById(person.id);
    if (member == null) continue;
    final name = member.name.trim().isEmpty ? '—' : member.name;
    result.add(l10n.mediaUsagePersonTag(name));
  }
  return result.toSet().toList(growable: false);
}

String _formatSize(int bytes, AppLocalizations l10n) {
  if (bytes < 1024) return l10n.backupSizeBytes(bytes);
  if (bytes < 1024 * 1024) {
    return l10n.backupSizeKb((bytes / 1024).toStringAsFixed(1));
  }
  return l10n.backupSizeMb((bytes / (1024 * 1024)).toStringAsFixed(1));
}
