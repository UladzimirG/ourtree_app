import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/family/domain/calendar_events.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/edit_mode_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/calendar_entry_editor.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/family/presentation/widgets/page_hero.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/widgets/member_avatar.dart';
import 'package:ourtree_app/features/settings/presentation/views/event_editor_screen.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

enum _CalendarView { month, year }

/// Семейный календарь: месяц или год, события и дни рождения.
class CalendarSection extends ConsumerStatefulWidget {
  const CalendarSection({
    super.key,
    required this.family,
  });

  final FamilyData family;

  @override
  ConsumerState<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends ConsumerState<CalendarSection> {
  late DateTime _cursor;
  _CalendarView _view = _CalendarView.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _cursor = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _cursor = DateTime(_cursor.year, _cursor.month + delta);
    });
  }

  void _shiftYear(int delta) {
    setState(() {
      _cursor = DateTime(_cursor.year + delta, _cursor.month);
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _cursor = DateTime(now.year, now.month);
    });
  }

  List<TimelineEvent> _eventsOn(DateTime day, AppLocalizations l10n) {
    return calendarEventsForDay(
      day: day,
      family: widget.family,
      birthdayTitle: (member) => l10n.calendarBirthdayTitle(member.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editMode = ref.watch(editModeProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      children: [
        PageHero(
          eyebrow: l10n.calendarEyebrow,
          title: l10n.calendarTitle,
          lede: l10n.calendarLede,
        ),
        _ViewChips(
          l10n: l10n,
          view: _view,
          onChanged: (view) => setState(() => _view = view),
        ),
        const SizedBox(height: 10),
        if (_view == _CalendarView.month)
          _MonthBody(
            family: widget.family,
            l10n: l10n,
            month: _cursor,
            editMode: editMode,
            onPrevious: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
            onToday: _goToday,
            onAdd: () => _openDay(context, DateTime.now()),
            onDayTap: (day) => _openDay(context, day),
          )
        else
          _YearBody(
            family: widget.family,
            l10n: l10n,
            year: _cursor.year,
            editMode: editMode,
            onPrevious: () => _shiftYear(-1),
            onNext: () => _shiftYear(1),
            onToday: _goToday,
            onAdd: () => _openDay(context, DateTime.now()),
            onDayTap: (day) => _openDay(context, day),
          ),
      ],
    );
  }

  Future<void> _openDay(BuildContext context, DateTime day) {
    final l10n = AppLocalizations.of(context)!;
    final editMode = ref.read(editModeProvider);
    final events = _eventsOn(day, l10n);

    return showCardSheet(context, (sheetContext) {
      final theme = Theme.of(sheetContext);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDisplayDate(day, localeName: l10n.localeName),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            Text(l10n.calendarNoEvents, style: theme.textTheme.bodyLarge)
          else
            for (var index = 0; index < events.length; index++) ...[
              if (index > 0)
                const Divider(color: Color(0x336F4B2A), height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          events[index].title,
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (events[index].place?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            events[index].place!.trim(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ],
                        if (stripRichText(events[index].text)
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            stripRichText(events[index].text),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (editMode && !isGeneratedBirthday(events[index]))
                    IconButton(
                      onPressed: () => _editEvent(
                        sheetContext,
                        context,
                        day,
                        events[index],
                      ),
                      tooltip: l10n.eventEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
            ],
          if (editMode) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _createEvent(sheetContext, context, day),
                icon: const Icon(Icons.event_available),
                label: Text(l10n.calendarAddEvent),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _createDate(sheetContext, context, day),
                icon: const Icon(Icons.add),
                label: Text(l10n.calendarAddDate),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(l10n.close),
            ),
          ),
        ],
      );
    });
  }

  void _editEvent(
    BuildContext sheetContext,
    BuildContext pageContext,
    DateTime day,
    TimelineEvent event,
  ) {
    final l10n = AppLocalizations.of(pageContext)!;
    Navigator.of(sheetContext).pop();
    if (event.isCalendarOnly) {
      showCalendarEntryEditor(
        pageContext,
        l10n: l10n,
        day: event.eventDate ?? day,
        event: event,
      );
      return;
    }
    Navigator.of(pageContext).push(
      MaterialPageRoute<void>(
        builder: (_) => EventEditorScreen(eventId: event.id),
      ),
    );
  }

  void _createEvent(
    BuildContext sheetContext,
    BuildContext pageContext,
    DateTime day,
  ) {
    final l10n = AppLocalizations.of(pageContext)!;
    final event = TimelineEvent(
      id: 'event-${DateTime.now().microsecondsSinceEpoch}',
      date: _iso(day),
      title: l10n.eventDefaultTitle,
      kind: EventKind.milestone,
    );
    ref.read(familyDataProvider.notifier).addTimelineEvent(event);
    Navigator.of(sheetContext).pop();
    Navigator.of(pageContext).push(
      MaterialPageRoute<void>(
        builder: (_) => EventEditorScreen(eventId: event.id),
      ),
    );
  }

  void _createDate(
    BuildContext sheetContext,
    BuildContext pageContext,
    DateTime day,
  ) {
    final l10n = AppLocalizations.of(pageContext)!;
    Navigator.of(sheetContext).pop();
    showCalendarEntryEditor(pageContext, l10n: l10n, day: day);
  }
}

String _iso(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

class _ViewChips extends StatelessWidget {
  const _ViewChips({
    required this.l10n,
    required this.view,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final _CalendarView view;
  final ValueChanged<_CalendarView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: view == _CalendarView.month,
          label: Text(l10n.calendarViewMonth),
          onSelected: (_) => onChanged(_CalendarView.month),
          selectedColor: AppColors.moss,
          labelStyle: TextStyle(
            color: view == _CalendarView.month ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.paper,
          side: BorderSide(color: AppColors.kraftDark.withValues(alpha: 0.2)),
        ),
        ChoiceChip(
          selected: view == _CalendarView.year,
          label: Text(l10n.calendarViewYear),
          onSelected: (_) => onChanged(_CalendarView.year),
          selectedColor: AppColors.moss,
          labelStyle: TextStyle(
            color: view == _CalendarView.year ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.paper,
          side: BorderSide(color: AppColors.kraftDark.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

class _MonthBody extends StatelessWidget {
  const _MonthBody({
    required this.family,
    required this.l10n,
    required this.month,
    required this.editMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onAdd,
    required this.onDayTap,
  });

  final FamilyData family;
  final AppLocalizations l10n;
  final DateTime month;
  final bool editMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onAdd;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      tilt: -0.4,
      child: Column(
        children: [
          _CalendarHeader(
            title: _capitalize(
              DateFormat.yMMMM(l10n.localeName).format(month),
            ),
            l10n: l10n,
            editMode: editMode,
            onPrevious: onPrevious,
            onNext: onNext,
            onToday: onToday,
            onAdd: onAdd,
          ),
          const SizedBox(height: 6),
          _MonthGrid(
            family: family,
            l10n: l10n,
            month: month,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

class _YearBody extends StatelessWidget {
  const _YearBody({
    required this.family,
    required this.l10n,
    required this.year,
    required this.editMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onAdd,
    required this.onDayTap,
  });

  final FamilyData family;
  final AppLocalizations l10n;
  final int year;
  final bool editMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onAdd;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaperCard(
          tilt: 0.3,
          child: _CalendarHeader(
            title: '$year',
            l10n: l10n,
            editMode: editMode,
            onPrevious: onPrevious,
            onNext: onNext,
            onToday: onToday,
            onAdd: onAdd,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 3 : 2;
            const gap = 10.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var month = 1; month <= 12; month++)
                  SizedBox(
                    width: width,
                    child: _MonthCard(
                      family: family,
                      l10n: l10n,
                      month: DateTime(year, month),
                      tilt: ((month % 3) - 1) * 0.35,
                      onDayTap: onDayTap,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.family,
    required this.l10n,
    required this.month,
    required this.tilt,
    required this.onDayTap,
  });

  final FamilyData family;
  final AppLocalizations l10n;
  final DateTime month;
  final double tilt;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      tilt: tilt,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Column(
        children: [
          Text(
            _capitalize(DateFormat.MMMM(l10n.localeName).format(month)),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          _MonthGrid(
            family: family,
            l10n: l10n,
            month: month,
            compact: true,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.title,
    required this.l10n,
    required this.editMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onAdd,
  });

  final String title;
  final AppLocalizations l10n;
  final bool editMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: l10n.calendarPreviousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: l10n.calendarNextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          onPressed: onToday,
          tooltip: l10n.calendarToday,
          icon: const Icon(Icons.today_outlined),
        ),
        if (editMode)
          IconButton(
            onPressed: onAdd,
            tooltip: l10n.calendarAddDate,
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.family,
    required this.l10n,
    required this.month,
    required this.onDayTap,
    this.compact = false,
  });

  final FamilyData family;
  final AppLocalizations l10n;
  final DateTime month;
  final ValueChanged<DateTime> onDayTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = firstDay.weekday - 1;
    final cellsCount = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();
    final weekdays = List<String>.generate(
      7,
      (index) => DateFormat.E(l10n.localeName).format(
        DateTime(2024, 1, 1).add(Duration(days: index)),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            for (final weekday in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    weekday,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: compact ? 7 : 11,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cellsCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: compact ? 2 : 6,
            crossAxisSpacing: compact ? 2 : 6,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - leading + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final day = DateTime(month.year, month.month, dayNumber);
            final events = calendarEventsForDay(
              day: day,
              family: family,
              birthdayTitle: (member) =>
                  l10n.calendarBirthdayTitle(member.name),
            );
            final isToday = day.year == today.year &&
                day.month == today.month &&
                day.day == today.day;
            final birthdayMembers = family.members
                .where(
                  (member) =>
                      member.showInCalendar != false &&
                      isSameMonthDay(member.birthdayDate, day),
                )
                .toList(growable: false);
            final hasBirthdayAvatar = birthdayMembers.isNotEmpty;
            final hasOtherEvents = events.any(
              (event) => !hasBirthdayAvatar || event.kind != EventKind.birth,
            );

            return _CalendarCell(
              day: dayNumber,
              isToday: isToday,
              hasEvents: hasOtherEvents,
              birthdayMembers: birthdayMembers,
              compact: compact,
              onTap: () => onDayTap(day),
            );
          },
        ),
      ],
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.hasEvents,
    required this.birthdayMembers,
    required this.compact,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool hasEvents;
  final List<FamilyMember> birthdayMembers;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: hasEvents ? AppColors.activeWash : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppColors.moss, width: 2) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: compact ? 9 : null,
                    height: 1.1,
                    fontWeight: hasEvents ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (!compact && birthdayMembers.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  _BirthdayAvatars(members: birthdayMembers),
                ],
                if (compact && (hasEvents || birthdayMembers.isNotEmpty)) ...[
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasEvents) _dot(AppColors.terracotta),
                      if (birthdayMembers.isNotEmpty) _dot(AppColors.moss),
                    ],
                  ),
                ],
              ],
            ),
            if (!compact && hasEvents)
              Positioned(
                right: birthdayMembers.isEmpty ? null : 3,
                bottom: 4,
                child: _dot(AppColors.terracotta),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Небольшие аватары именинников: до двух, со сдвигом друг на друга.
class _BirthdayAvatars extends StatelessWidget {
  const _BirthdayAvatars({required this.members});

  final List<FamilyMember> members;

  @override
  Widget build(BuildContext context) {
    final visible = members.take(2).toList(growable: false);
    final width = 16.0 + (visible.length - 1) * 12.0;
    final names = members
        .map((member) => member.name.trim().isEmpty ? '—' : member.name.trim())
        .join(', ');

    return Tooltip(
      message: names,
      child: SizedBox(
        width: width,
        height: 16,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < visible.length; index++)
              Positioned(
                left: index * 12.0,
                child: MemberAvatar(member: visible[index], size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
