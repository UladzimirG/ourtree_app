import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/family/presentation/widgets/page_hero.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/widgets/member_avatar.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Семейный календарь: месяцы, отмеченные дни и события по нажатию.
class CalendarSection extends StatefulWidget {
  const CalendarSection({
    super.key,
    required this.family,
  });

  final FamilyData family;

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  late DateTime _cursor;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final today = DateTime.now();
    final firstDay = DateTime(_cursor.year, _cursor.month);
    final daysInMonth = DateTime(_cursor.year, _cursor.month + 1, 0).day;
    final leading = firstDay.weekday - 1;
    final cellsCount = ((leading + daysInMonth) / 7).ceil() * 7;
    final monthTitle = _capitalize(
      DateFormat.yMMMM(l10n.localeName).format(firstDay),
    );
    final weekdays = List<String>.generate(
      7,
      (index) => DateFormat.E(l10n.localeName).format(
        DateTime(2024, 1, 1).add(Duration(days: index)),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      children: [
        PageHero(
          eyebrow: l10n.calendarEyebrow,
          title: l10n.calendarTitle,
          lede: l10n.calendarLede,
        ),
        PaperCard(
          tilt: -0.4,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _shiftMonth(-1),
                    tooltip: l10n.calendarPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      monthTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shiftMonth(1),
                    tooltip: l10n.calendarNextMonth,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final weekday in weekdays)
                    Expanded(
                      child: Center(
                        child: Text(
                          weekday,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - leading + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final day = DateTime(
                    _cursor.year,
                    _cursor.month,
                    dayNumber,
                  );
                  final dayEvents = _eventsOnDay(day, widget.family, l10n);
                  final isToday = day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;
                  final birthdayMembers = widget.family.members
                      .where(
                        (member) =>
                            member.showInCalendar != false &&
                            isSameMonthDay(member.birthdayDate, day),
                      )
                      .toList(growable: false);
                  // Точка нужна только для событий, которые не показаны
                  // аватаром именинника.
                  final hasBirthdayAvatar = birthdayMembers.isNotEmpty;
                  final hasOtherEvents = dayEvents.any(
                    (event) =>
                        !hasBirthdayAvatar || event.kind != EventKind.birth,
                  );

                  return _CalendarCell(
                    day: dayNumber,
                    isToday: isToday,
                    hasEvents: hasOtherEvents,
                    birthdayMembers: birthdayMembers,
                    onTap: () => _openDay(context, day, dayEvents, l10n),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openDay(
    BuildContext context,
    DateTime day,
    List<TimelineEvent> events,
    AppLocalizations l10n,
  ) {
    return showCardSheet(context, (sheetContext) {
      final theme = Theme.of(sheetContext);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDisplayDate(day),
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
              Text(events[index].title, style: theme.textTheme.headlineSmall),
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
              if (stripRichText(events[index].text).trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  stripRichText(events[index].text),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
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
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.hasEvents,
    required this.birthdayMembers,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool hasEvents;
  final List<FamilyMember> birthdayMembers;
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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.1,
                    fontWeight: hasEvents ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (birthdayMembers.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 1),
                  _BirthdayAvatars(members: birthdayMembers),
                ],
              ],
            ),
            if (hasEvents)
              Positioned(
                right: birthdayMembers.isEmpty ? null : 3,
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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

List<TimelineEvent> _eventsOnDay(
  DateTime day,
  FamilyData family,
  AppLocalizations l10n,
) {
  bool sameDay(DateTime? date) =>
      date != null &&
      date.year == day.year &&
      date.month == day.month &&
      date.day == day.day;

  final events = family.timelineEvents
      .where(
          (event) => event.showInCalendar != false && sameDay(event.eventDate))
      .toList(growable: false);

  final birthdayEvents = <TimelineEvent>[];
  for (final member in family.members) {
    if (member.showInCalendar == false) continue;
    // День рождения повторяется каждый год, поэтому год не сравниваем.
    if (!isSameMonthDay(member.birthdayDate, day)) continue;
    final hasBirthEvent = events.any(
      (event) => event.kind == EventKind.birth && event.memberId == member.id,
    );
    if (hasBirthEvent) continue;
    birthdayEvents.add(
      TimelineEvent(
        id: 'calendar-birthday-${member.id}',
        date: member.birthday,
        title: l10n.calendarBirthdayTitle(member.name),
        kind: EventKind.birth,
        memberId: member.id,
      ),
    );
  }

  return [...events, ...birthdayEvents];
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
