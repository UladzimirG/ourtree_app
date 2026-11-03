import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/edit_mode_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/timeline_order_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/event_media_grid.dart';
import 'package:ourtree_app/features/family/presentation/widgets/page_hero.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/views/event_editor_screen.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

const List<double> _tilts = <double>[-1.2, 0.8, -0.5, 1.1, -0.9, 0.4];

/// Таймлайн семейных событий — главный раздел оригинального приложения.
class TimelineSection extends ConsumerStatefulWidget {
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
  ConsumerState<TimelineSection> createState() => _TimelineSectionState();
}

class _TimelineSectionState extends ConsumerState<TimelineSection> {
  /// Новое событие временно поднимаем наверх, чтобы его было видно сразу.
  String? _pinnedEventId;
  String? _highlightedEventId;
  Timer? _highlightTimer;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _pinNewEvent(TimelineEvent event) {
    _highlightTimer?.cancel();
    setState(() {
      _pinnedEventId = event.id;
      _highlightedEventId = event.id;
    });
    _highlightTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() => _highlightedEventId = null);
    });
  }

  Future<void> _addEvent() async {
    final l10n = AppLocalizations.of(context)!;
    final event = TimelineEvent(
      id: 'event-${DateTime.now().microsecondsSinceEpoch}',
      date: DateTime.now().toIso8601String().split('T').first,
      title: l10n.eventDefaultTitle,
      kind: EventKind.milestone,
    );
    ref.read(familyDataProvider.notifier).addTimelineEvent(event);
    _pinNewEvent(event);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventEditorScreen(eventId: event.id),
      ),
    );
  }

  void _openEventEditor(TimelineEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventEditorScreen(eventId: event.id),
      ),
    );
  }

  List<TimelineEvent> _orderedEvents(TimelineOrder order) {
    final events = widget.family.timelineEvents
        .where((event) => event.showsInTimeline)
        .toList(growable: true);
    events.sort(
      order == TimelineOrder.newestFirst
          ? (a, b) => b.date.compareTo(a.date)
          : (a, b) => a.date.compareTo(b.date),
    );

    final pinned = _pinnedEventId;
    if (pinned != null) {
      final index = events.indexWhere((event) => event.id == pinned);
      if (index > 0) {
        events.insert(0, events.removeAt(index));
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editMode = ref.watch(editModeProvider);
    final order = ref.watch(timelineOrderControllerProvider);
    final events = _orderedEvents(order);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      children: [
        PageHero(
          eyebrow: l10n.timelineEyebrow,
          title: l10n.timelineTitle,
          lede: l10n.timelineLede,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OrderChip(
              label: l10n.timelineOrderOldest,
              selected: order == TimelineOrder.oldestFirst,
              onTap: () => ref
                  .read(timelineOrderControllerProvider.notifier)
                  .select(TimelineOrder.oldestFirst),
            ),
            _OrderChip(
              label: l10n.timelineOrderNewest,
              selected: order == TimelineOrder.newestFirst,
              onTap: () => ref
                  .read(timelineOrderControllerProvider.notifier)
                  .select(TimelineOrder.newestFirst),
            ),
          ],
        ),
        if (editMode) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _addEvent,
              icon: const Icon(Icons.add),
              label: Text(l10n.eventAdd),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (events.isEmpty)
          PaperCard(child: Text(l10n.timelineEmpty))
        else
          for (var index = 0; index < events.length; index++)
            _TimelineRow(
              family: widget.family,
              event: events[index],
              tilt: _tilts[index % _tilts.length],
              isLast: index == events.length - 1,
              showMedia: widget.showMedia,
              editMode: editMode,
              highlighted: _highlightedEventId == events[index].id,
              onTap: () => widget.onEventTap(events[index]),
              onEdit: () => _openEventEditor(events[index]),
            ),
      ],
    );
  }
}

class _OrderChip extends StatelessWidget {
  const _OrderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: AppColors.moss,
      // Компактная подпись: две «таблетки» помещаются в одну строку даже на
      // узком экране, иначе они съедают пол-экрана по высоте.
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.ink,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: AppColors.paper,
      side: BorderSide(color: AppColors.kraftDark.withValues(alpha: 0.2)),
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
    required this.editMode,
    required this.highlighted,
    required this.onTap,
    required this.onEdit,
  });

  final FamilyData family;
  final TimelineEvent event;
  final double tilt;
  final bool isLast;
  final bool showMedia;
  final bool editMode;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget card = PaperCard(
      tilt: tilt,
      onTap: onTap,
      child: _TimelineCardBody(
        family: family,
        event: event,
        l10n: l10n,
        showMedia: showMedia,
      ),
    );

    if (highlighted) {
      card = TweenAnimationBuilder<double>(
        key: ValueKey<String>('highlight-${event.id}'),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1600),
        builder: (context, value, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.terracotta.withValues(
                  alpha: 0.35 * (1 - value),
                ),
                blurRadius: 24 * (1 - value) + 4,
                spreadRadius: 2 * (1 - value),
              ),
            ],
          ),
          child: child,
        ),
        child: card,
      );
    }

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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    card,
                    if (highlighted)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _NewBadge(label: l10n.eventNewBadge),
                      ),
                    if (editMode)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Tooltip(
                          message: l10n.eventEdit,
                          child: Material(
                            color: AppColors.paper,
                            elevation: 3,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onEdit,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.terracotta,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.terracotta,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
          EventMediaGrid(
            media: family.mediaForEvent(event),
            placeholderLabel: l10n.mediaPlaceholder,
            eyebrow: l10n.timelineEyebrow,
            title: event.title,
            subtitle: dateLabel,
            openViewer: false,
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
