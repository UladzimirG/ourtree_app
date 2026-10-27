import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_video_player.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Один элемент просмотрщика медиа.
class MediaViewerItem {
  const MediaViewerItem({
    required this.source,
    this.type = MediaType.image,
    this.name,
    this.caption,
    this.position,
    this.zoom,
  });

  final String source;
  final MediaType type;
  final String? name;
  final String? caption;
  final PhotoPosition? position;
  final double? zoom;
}

/// Открывает просмотрщик в стиле остальных «бумажных» окон.
Future<void> showMediaViewer(
  BuildContext context, {
  required List<MediaViewerItem> items,
  int initialIndex = 0,
  String? eyebrow,
  String? title,
  String? subtitle,
}) {
  final available = items
      .where((item) => item.source.trim().isNotEmpty)
      .toList(growable: false);
  if (available.isEmpty) return Future<void>.value();

  return showCardSheet(
    context,
    (sheetContext) => _MediaViewerSheet(
      items: available,
      initialIndex: initialIndex.clamp(0, available.length - 1),
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
    ),
    maxWidth: 760,
  );
}

class _MediaViewerSheet extends StatefulWidget {
  const _MediaViewerSheet({
    required this.items,
    required this.initialIndex,
    this.eyebrow,
    this.title,
    this.subtitle,
  });

  final List<MediaViewerItem> items;
  final int initialIndex;
  final String? eyebrow;
  final String? title;
  final String? subtitle;

  @override
  State<_MediaViewerSheet> createState() => _MediaViewerSheetState();
}

class _MediaViewerSheetState extends State<_MediaViewerSheet> {
  late final PageController _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.items.length) return;
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final item = widget.items[_index];
    final viewerHeight =
        math.min(MediaQuery.sizeOf(context).height * 0.62, 560.0);
    final caption = item.caption?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.eyebrow?.trim().isNotEmpty == true)
          Text(
            widget.eyebrow!.trim(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSoft,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.title?.trim().isNotEmpty == true
                    ? widget.title!.trim()
                    : l10n.mediaTitle,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_index + 1} / ${widget.items.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSoft,
                ),
              ),
            ),
          ],
        ),
        if (widget.subtitle?.trim().isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              widget.subtitle!.trim(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                color: AppColors.terracotta,
                fontSize: 18,
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: viewerHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: const Color(0xFF1C1712),
              child: PageView.builder(
                controller: _pages,
                itemCount: widget.items.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => _MediaViewerPage(
                  item: widget.items[index],
                ),
              ),
            ),
          ),
        ),
        if (caption != null && caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              tooltip: l10n.mediaViewerPrevious,
              onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                widget.items.length > 1 ? '${_index + 1}' : '',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: l10n.mediaViewerNext,
              onPressed: _index < widget.items.length - 1
                  ? () => _goTo(_index + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: 4),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _MediaThumbnail(
                item: widget.items[index],
                selected: index == _index,
                onTap: () => _goTo(index),
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ),
      ],
    );
  }
}

class _MediaViewerPage extends StatelessWidget {
  const _MediaViewerPage({required this.item});

  final MediaViewerItem item;

  @override
  Widget build(BuildContext context) {
    if (item.type == MediaType.video) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: MediaVideoPlayer(
          source: item.source,
          name: item.name,
        ),
      );
    }

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      // Горизонтальные свайпы отдаём PageView, иначе листать фото нельзя.
      panEnabled: false,
      child: Center(
        child: FamilyPhoto(
          source: item.source,
          fit: BoxFit.contain,
          alignment: photoAlignment(item.position),
          fallback: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.paper,
            size: 42,
          ),
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  const _MediaThumbnail({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MediaViewerItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 58,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.terracotta : const Color(0x336F4B2A),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: item.type == MediaType.video
              ? const ColoredBox(
                  color: Color(0xFF1C1712),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.paper,
                    size: 22,
                  ),
                )
              : FamilyPhoto(
                  source: item.source,
                  fallback: const ColoredBox(
                    color: AppColors.kraftWash,
                    child: Icon(Icons.image_outlined, size: 20),
                  ),
                ),
        ),
      ),
    );
  }
}
