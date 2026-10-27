import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/widgets/interactive_photo_crop.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_video_player.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Максимальный размер файла, который держим в памяти сессии.
const int mediaMaxBytes = 20 * 1024 * 1024;

/// Универсальный редактор фотографий и видео.
///
/// Используется для дня рождения, галереи профиля и медиа события. Позволяет
/// загрузить файлы с устройства, добавить запись по ссылке/пути, изменить
/// подпись и тип, отметить людей на фото и связать файл с событиями.
class MediaListEditor extends ConsumerStatefulWidget {
  const MediaListEditor({
    super.key,
    required this.value,
    required this.onChanged,
    required this.l10n,
    this.members = const <FamilyMember>[],
    this.events = const <TimelineEvent>[],
    this.ownerId,
    this.title,
    this.showMembers = true,
    this.showEvents = true,
  });

  final List<FamilyMedia> value;
  final ValueChanged<List<FamilyMedia>> onChanged;
  final AppLocalizations l10n;
  final List<FamilyMember> members;
  final List<TimelineEvent> events;
  final String? ownerId;
  final String? title;
  final bool showMembers;
  final bool showEvents;

  @override
  ConsumerState<MediaListEditor> createState() => _MediaListEditorState();
}

class _MediaListEditorState extends ConsumerState<MediaListEditor> {
  bool _busy = false;

  void _replace(int index, FamilyMedia media) {
    widget.onChanged([
      for (var i = 0; i < widget.value.length; i++)
        if (i == index) media else widget.value[i],
    ]);
  }

  void _remove(int index) {
    widget.onChanged([
      for (var i = 0; i < widget.value.length; i++)
        if (i != index) widget.value[i],
    ]);
  }

  FamilyMedia _linkFromAsset(MediaAsset asset) => FamilyMedia(
        id: _newMediaId(),
        mediaId: asset.id,
        source: asset.source,
        type: asset.type,
        name: asset.name,
        people: asset.people,
      );

  void _attachAsset(MediaAsset asset) {
    final exists = widget.value.any(
      (media) => media.mediaId == asset.id || media.source == asset.source,
    );
    if (exists) return;
    widget.onChanged([...widget.value, _linkFromAsset(asset)]);
  }

  Future<void> _addByLink() async {
    final l10n = widget.l10n;
    final controller = TextEditingController();
    final source = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.mediaAddByLink),
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

    final asset = MediaAsset(
      id: 'asset-${DateTime.now().microsecondsSinceEpoch}',
      source: source,
      type: _typeForName(source),
    );
    ref.read(familyDataProvider.notifier).upsertMediaAsset(asset);
    _attachAsset(asset);
  }

  Future<void> _pickFromLibrary() async {
    final family = ref.read(familyDataProvider).valueOrNull;
    final assets = family?.mediaLibrary ?? const <MediaAsset>[];
    if (assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.mediaLibraryEmpty)),
      );
      return;
    }

    final selected = await showModalBottomSheet<MediaAsset>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              widget.l10n.mediaFromLibrary,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          for (final asset in assets)
            ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: asset.isVideo
                      ? const ColoredBox(
                          color: AppColors.kraftWash,
                          child: Icon(Icons.videocam_outlined),
                        )
                      : FamilyPhoto(
                          source: asset.source,
                          fallback: const ColoredBox(
                            color: AppColors.kraftWash,
                            child: Icon(Icons.image_outlined),
                          ),
                        ),
                ),
              ),
              title: Text(
                asset.name?.trim().isNotEmpty == true
                    ? asset.name!
                    : widget.l10n.mediaTitle,
              ),
              subtitle: Text(
                asset.isVideo
                    ? widget.l10n.mediaTypeVideo
                    : widget.l10n.mediaTypeImage,
              ),
              onTap: () => Navigator.of(sheetContext).pop(asset),
            ),
        ],
      ),
    );
    if (selected != null) _attachAsset(selected);
  }

  Future<void> _pickFiles() async {
    setState(() => _busy = true);
    final l10n = widget.l10n;
    final added = <FamilyMedia>[];
    String? error;

    try {
      final files = await FilePicker.pickFiles(type: FileType.media);
      if (files.isEmpty) return;

      for (final file in files) {
        final size = file.lengthSync() ?? await file.length() ?? 0;
        if (size > mediaMaxBytes) {
          error = l10n.mediaUploadTooLarge(file.name);
          continue;
        }
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          error = l10n.mediaUploadEmpty;
          continue;
        }
        final hash = sha256.convert(bytes).toString();
        final existing = ref
            .read(familyDataProvider)
            .valueOrNull
            ?.findDuplicateMedia(
              hash: hash,
              name: file.name,
              size: bytes.length,
            );
        if (existing != null) {
          added.add(_linkFromAsset(existing));
          error = l10n.mediaDuplicateAttached;
          continue;
        }
        final storedId = await MediaStorage.instance.saveBytes(
          bytes,
          name: file.name,
        );
        final asset = MediaAsset(
          id: 'asset-$storedId',
          source: 'hive://$storedId',
          type: _typeForName(file.name),
          name: file.name,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          size: bytes.length,
          hash: hash,
        );
        ref.read(familyDataProvider.notifier).upsertMediaAsset(asset);
        added.add(_linkFromAsset(asset));
      }
    } catch (_) {
      error = l10n.mediaUploadFailed;
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    if (added.isNotEmpty) widget.onChanged([...widget.value, ...added]);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final family = ref.watch(familyDataProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title ?? l10n.mediaTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: _busy ? null : _pickFiles,
              icon: Icon(_busy ? Icons.hourglass_top : Icons.upload_file),
              label: Text(_busy ? l10n.mediaUploading : l10n.mediaUpload),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          children: [
            TextButton.icon(
              onPressed: _pickFromLibrary,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.mediaFromLibrary),
            ),
            TextButton.icon(
              onPressed: _addByLink,
              icon: const Icon(Icons.add_link),
              label: Text(l10n.mediaAddByLink),
            ),
          ],
        ),
        if (widget.value.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.mediaEmpty, style: theme.textTheme.bodyMedium),
          )
        else
          for (var index = 0; index < widget.value.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MediaTile(
                key: ValueKey(widget.value[index].id),
                media: widget.value[index],
                asset: family?.assetById(widget.value[index].mediaId),
                l10n: l10n,
                members: widget.members,
                events: widget.events,
                ownerId: widget.ownerId,
                showMembers: widget.showMembers,
                showEvents: widget.showEvents,
                onChanged: (media) => _replace(index, media),
                onAssetChanged: (asset) => ref
                    .read(familyDataProvider.notifier)
                    .upsertMediaAsset(asset),
                onRemove: () => _remove(index),
              ),
            ),
        Text(l10n.mediaUploadHint, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _MediaTile extends StatefulWidget {
  const _MediaTile({
    super.key,
    required this.media,
    required this.asset,
    required this.l10n,
    required this.members,
    required this.events,
    required this.onChanged,
    required this.onAssetChanged,
    required this.onRemove,
    required this.showMembers,
    required this.showEvents,
    this.ownerId,
  });

  final FamilyMedia media;
  final MediaAsset? asset;
  final ValueChanged<MediaAsset> onAssetChanged;
  final AppLocalizations l10n;
  final List<FamilyMember> members;
  final List<TimelineEvent> events;
  final String? ownerId;
  final bool showMembers;
  final bool showEvents;
  final ValueChanged<FamilyMedia> onChanged;
  final VoidCallback onRemove;

  @override
  State<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<_MediaTile> {
  late final TextEditingController _caption;
  final FocusNode _captionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(text: widget.media.caption ?? '');
  }

  @override
  void didUpdateWidget(covariant _MediaTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final caption = widget.media.caption ?? '';
    if (!_captionFocus.hasFocus && _caption.text != caption) {
      _caption.text = caption;
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    _captionFocus.dispose();
    super.dispose();
  }

  void _togglePerson(String id, bool present) {
    final asset = widget.asset;
    final base = asset?.people ?? widget.media.people;
    final people = present
        ? [
            ...base.where((person) => person.id != id),
            GalleryPerson(id: id),
          ]
        : base.where((person) => person.id != id).toList(growable: false);
    if (asset != null) {
      widget.onAssetChanged(asset.copyWith(people: people));
    } else {
      widget.onChanged(widget.media.copyWith(people: people));
    }
  }

  void _updatePersonCaption(String memberId, String value) {
    final asset = widget.asset;
    if (asset == null) return;
    final people = [
      for (final person in asset.people)
        if (person.id == memberId)
          person.copyWith(
            caption: () => value.trim().isEmpty ? null : value,
          )
        else
          person,
    ];
    widget.onAssetChanged(asset.copyWith(people: people));
  }

  void _toggleEvent(String id, bool present) {
    final current = widget.media.eventIds;
    final eventIds = present
        ? {...current, id}.toList(growable: false)
        : current.where((eventId) => eventId != id).toList(growable: false);
    widget.onChanged(widget.media.copyWith(eventIds: eventIds));
  }

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.tryParse(widget.media.source.trim());
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.mediaLinkCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final media = widget.media;
    final caption = (media.caption ?? '').trim();
    final title = caption.isNotEmpty
        ? caption
        : (media.name?.trim().isNotEmpty == true
            ? media.name!
            : l10n.mediaTitle);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.kraftWash,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: SizedBox(
          width: 48,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: media.type.isVideo
                ? const ColoredBox(
                    color: AppColors.paper,
                    child: Icon(Icons.videocam_outlined),
                  )
                : FamilyPhoto(
                    source: media.source,
                    alignment: photoAlignment(media.position),
                    zoom: media.zoom ?? 1,
                    fallback: const ColoredBox(
                      color: AppColors.paper,
                      child: Icon(Icons.image_outlined),
                    ),
                  ),
          ),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          media.type.isVideo ? l10n.mediaTypeVideo : l10n.mediaTypeImage,
          style: theme.textTheme.bodySmall,
        ),
        children: _details(context),
      ),
    );
  }

  List<Widget> _details(BuildContext context) {
    final l10n = widget.l10n;
    final media = widget.media;
    final theme = Theme.of(context);

    return [
      if (media.type.isVideo && media.source.trim().isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MediaVideoPlayer(
            source: media.source,
            name: media.name,
          ),
        ),
      if (!media.type.isVideo && media.source.trim().isNotEmpty) ...[
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FamilyPhoto(
              source: media.source,
              alignment: photoAlignment(media.position),
              zoom: media.zoom ?? 1,
              fallback: const ColoredBox(
                color: AppColors.paper,
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
      _captionLabel(l10n.mediaCaptionField),
      TextField(
        controller: _caption,
        focusNode: _captionFocus,
        maxLines: 2,
        minLines: 1,
        decoration: settingsInputDecoration(
          hint: l10n.mediaCaptionField,
          dense: true,
        ),
        onChanged: (value) =>
            widget.onChanged(media.copyWith(caption: () => value)),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.mediaTypeField.toUpperCase(),
              style: settingsCaptionStyle(theme),
            ),
          ),
          DropdownButton<MediaType>(
            value: media.type,
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
              if (type != null) widget.onChanged(media.copyWith(type: type));
            },
          ),
        ],
      ),
      _cropSection(context),
      if (widget.showMembers) _peopleSection(context),
      if (widget.showEvents) _eventsSection(context),
      _actions(context),
    ];
  }

  Widget _cropSection(BuildContext context) {
    if (widget.media.type.isVideo ||
        widget.media.source.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _captionLabel(widget.l10n.mediaCropField),
        InteractivePhotoCrop(
          source: widget.media.source,
          position: widget.media.position ?? PhotoPosition.center,
          zoom: widget.media.zoom ?? 1.4,
          onChanged: (position, zoom) => widget.onChanged(
            widget.media.copyWith(
              position: () => position,
              zoom: () => zoom,
            ),
          ),
        ),
      ],
    );
  }

  Widget _peopleSection(BuildContext context) {
    final others = widget.members
        .where((member) => member.id != widget.ownerId)
        .toList(growable: false);
    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _captionLabel(widget.l10n.mediaPeopleField),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final member in others)
              FilterChip(
                label: Text(member.name.trim().isEmpty ? '—' : member.name),
                selected: (widget.asset?.people ?? widget.media.people)
                    .any((person) => person.id == member.id),
                onSelected: (selected) => _togglePerson(member.id, selected),
              ),
          ],
        ),
        for (final member in others)
          if ((widget.asset?.people ?? widget.media.people)
              .any((person) => person.id == member.id))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                key: ValueKey('${widget.media.id}-caption-${member.id}'),
                initialValue: (widget.asset?.people ?? widget.media.people)
                        .firstWhere((person) => person.id == member.id)
                        .caption ??
                    '',
                decoration: settingsInputDecoration(
                  hint: widget.l10n.mediaPersonCaption(
                    member.name.trim().isEmpty ? '—' : member.name,
                  ),
                  dense: true,
                ),
                onChanged: (value) => _updatePersonCaption(member.id, value),
              ),
            ),
        const SizedBox(height: 4),
        Text(
          widget.l10n.mediaPeopleHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _eventsSection(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _captionLabel(widget.l10n.mediaEventsField),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final event in widget.events)
              FilterChip(
                label: Text(event.title.trim().isEmpty ? '—' : event.title),
                selected: widget.media.isLinkedToEvent(event.id),
                onSelected: (selected) => _toggleEvent(event.id, selected),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.l10n.mediaEventsHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isOpenableLink(widget.media.source))
          TextButton.icon(
            onPressed: () => _openLink(context),
            icon: const Icon(Icons.open_in_new),
            label: Text(widget.l10n.mediaOpenLink),
          ),
        TextButton.icon(
          onPressed: widget.onRemove,
          style: TextButton.styleFrom(foregroundColor: AppColors.terracotta),
          icon: const Icon(Icons.delete_outline),
          label: Text(widget.l10n.mediaRemove),
        ),
      ],
    );
  }

  Widget _captionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: settingsCaptionStyle(Theme.of(context)),
      ),
    );
  }
}


String _newMediaId() => 'media-${DateTime.now().microsecondsSinceEpoch}';

MediaType _typeForName(String name) {
  final lower = name.toLowerCase();
  return _videoExtensions.any(lower.endsWith) ? MediaType.video : MediaType.image;
}

const List<String> _videoExtensions = <String>[
  '.mp4',
  '.webm',
  '.mov',
  '.m4v',
  '.avi',
  '.mkv',
];

bool _isOpenableLink(String source) {
  final value = source.trim();
  return value.startsWith('http://') || value.startsWith('https://');
}

