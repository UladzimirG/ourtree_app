import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/family/presentation/widgets/page_hero.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_viewer.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

const List<double> _tilts = <double>[-1.2, 0.8, -0.5, 1.1, -0.9, 0.4];

/// Таймлайн семейных событий — главный раздел оригинального приложения.
class TimelineSection extends StatelessWidget {
  const TimelineSection({
    super.key,
    required this.family,
    required this.onEventTap,
    this.showMedia = true,
  });

  final FamilyData family;
  final ValueChanged<TimelineEvent> onEventTap;
  final bool showMedia;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final events = family.sortedTimelineEvents;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      children: [
        PageHero(
          eyebrow: l10n.timelineEyebrow,
          title: l10n.timelineTitle,
          lede: l10n.timelineLede,
        ),
        if (events.isEmpty)
          PaperCard(child: Text(l10n.timelineEmpty))
        else
          for (var index = 0; index < events.length; index++)
            _TimelineRow(
              family: family,
              event: events[index],
              tilt: _tilts[index % _tilts.length],
              isLast: index == events.length - 1,
              showMedia: showMedia,
              onTap: () => onEventTap(events[index]),
            ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.family,
    required this.event,
    required this.tilt,
    required this.isLast,
    required this.showMedia,
    required this.onTap,
  });

  final FamilyData family;
  final TimelineEvent event;
  final double tilt;
  final bool isLast;
  final bool showMedia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 25,
            top: 38,
            bottom: 0,
            child: CustomPaint(
              painter: const _DashedLinePainter(),
              child: const SizedBox(width: 3),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Align(
                alignment: Alignment.topCenter,
                child: _TimelineDot(kind: event.kind),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 2,
                  top: 8,
                  bottom: isLast ? 0 : 24,
                ),
                child: PaperCard(
                  tilt: tilt,
                  onTap: onTap,
                  child: _TimelineCardBody(
                    family: family,
                    event: event,
                    l10n: l10n,
                    showMedia: showMedia,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.kind});

  final EventKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.paper,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        _eventIcon(kind),
        size: 20,
        color: AppColors.terracotta,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x996F4B2A)
      ..strokeWidth = 3;

    const double dash = 10;
    const double gap = 6;
    for (double y = 0; y < size.height; y += dash + gap) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, math.min(y + dash, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

IconData _eventIcon(EventKind kind) => switch (kind) {
      EventKind.meeting => Icons.favorite_border,
      EventKind.date => Icons.local_florist_outlined,
      EventKind.wedding => Icons.auto_awesome,
      EventKind.church => Icons.account_balance_outlined,
      EventKind.birth => Icons.child_care,
      EventKind.trip => Icons.explore_outlined,
      EventKind.milestone => Icons.flag_outlined,
    };

class _TimelineCardBody extends StatelessWidget {
  const _TimelineCardBody({
    required this.family,
    required this.event,
    required this.l10n,
    required this.showMedia,
  });

  final FamilyData family;
  final TimelineEvent event;
  final AppLocalizations l10n;
  final bool showMedia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = event.eventDate;
    final dateLabel = date == null
        ? formatDisplayDateFromIso(event.date, localeName: l10n.localeName)
        : formatDisplayDate(date, localeName: l10n.localeName);
    final elapsed = elapsedSince(event.date);
    final text = stripRichText(event.text);
    final place = event.place?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMedia) ...[
          _EventMedia(
            media: family.mediaForEvent(event),
            placeholderLabel: l10n.mediaPlaceholder,
            eyebrow:
                formatDisplayDateFromIso(event.date, localeName: l10n.localeName),
            title: event.title,
            subtitle: event.place,
          ),
          const SizedBox(height: 10),
        ],
        Text(
          dateLabel,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
        ),
        const SizedBox(height: 4),
        Text(event.title, style: theme.textTheme.headlineSmall),
        if (place != null && place.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            place,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: AppColors.terracotta,
            ),
          ),
        ],
        if (text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
        if (event.showElapsed == true && !elapsed.isZero) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.mossWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${l10n.timelineElapsedYears(elapsed.years)}, '
              '${l10n.timelineElapsedMonths(elapsed.months)}, '
              '${l10n.timelineElapsedDays(elapsed.days)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EventMedia extends StatelessWidget {
  const _EventMedia({
    required this.media,
    required this.placeholderLabel,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final List<FamilyMedia> media;
  final String placeholderLabel;
  final String eyebrow;
  final String title;
  final String? subtitle;

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
                    onTap: () => showMediaViewer(
                      context,
                      items: viewerItems,
                      initialIndex: index,
                      eyebrow: eyebrow,
                      title: title,
                      subtitle: subtitle,
                    ),
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
  const _EventMediaFrame({required this.entry, required this.onTap});

  final _MediaEntry entry;
  final VoidCallback onTap;

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
            zoom: entry.zoom ?? 1.4,
            fallback: fallback,
          );
    final caption = entry.caption?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
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


