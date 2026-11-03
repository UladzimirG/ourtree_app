import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/photo_crop.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_viewer.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Сетка фотографий события.
///
/// В карточке таймлайна используется с [openViewer] = false: нажатие на любую
/// точку карточки открывает событие целиком. В полном описании события —
/// с [openViewer] = true, чтобы фото можно было посмотреть отдельно.
class EventMediaGrid extends StatelessWidget {
  const EventMediaGrid({
    super.key,
    required this.media,
    required this.placeholderLabel,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.openViewer = true,
  });

  final List<FamilyMedia> media;
  final String placeholderLabel;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool openViewer;

  @override
  Widget build(BuildContext context) {
    final items = <_MediaEntry>[
      for (final entry in media)
        if (entry.source.trim().isNotEmpty)
          _MediaEntry(
            source: entry.source.trim(),
            name: entry.name,
            type: entry.type,
            caption: entry.caption,
            position: entry.position,
            zoom: entry.zoom,
          ),
    ];

    if (items.isEmpty) {
      return _MediaPlaceholder(label: placeholderLabel);
    }

    final viewerItems = [
      for (final entry in items)
        MediaViewerItem(
          source: entry.source,
          type: entry.type,
          name: entry.name,
          caption: entry.caption,
          position: entry.position,
          zoom: entry.zoom,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = items.length == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 8) / 2;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: width,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _EventMediaFrame(
                    entry: items[index],
                    onTap: openViewer
                        ? () => showMediaViewer(
                              context,
                              items: viewerItems,
                              initialIndex: index,
                              eyebrow: eyebrow,
                              title: title,
                              subtitle: subtitle,
                            )
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EventMediaFrame extends StatelessWidget {
  const _EventMediaFrame({required this.entry, this.onTap});

  final _MediaEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fallback = _PhotoFallback(
      icon: entry.type == MediaType.video
          ? Icons.play_circle_outline
          : Icons.broken_image_outlined,
    );
    final content = entry.type == MediaType.video
        ? const ColoredBox(
            color: Color(0xFF1C1712),
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: AppColors.paper,
                size: 36,
              ),
            ),
          )
        : FamilyPhoto(
            source: entry.source,
            fit: BoxFit.cover,
            alignment: photoAlignment(entry.position),
            zoom: photoZoomOrDefault(entry.zoom),
            fallback: fallback,
          );
    final caption = entry.caption?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (onTap == null)
            ColoredBox(
              color: const Color(0x1F6F4B2A),
              child: content,
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: ColoredBox(
                color: const Color(0x1F6F4B2A),
                child: content,
              ),
            ),
          if (caption != null && caption.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x002A1B12), Color(0xCC2A1B12)],
                  ),
                ),
                child: Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, size: 32, color: AppColors.inkSoft),
    );
  }
}

class _MediaEntry {
  const _MediaEntry({
    required this.source,
    required this.type,
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

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 122,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x2E8A5A2E), Color(0x1F6F4B2A)],
        ),
        border: Border.all(color: const Color(0x1A6F4B2A)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_outlined,
            size: 26,
            color: AppColors.inkSoft,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: AppColors.inkSoft,
                ),
          ),
        ],
      ),
    );
  }
}
