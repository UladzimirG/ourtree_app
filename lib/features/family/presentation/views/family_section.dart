import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/edit_mode_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/page_hero.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/widgets/member_avatar.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:ourtree_app/features/settings/presentation/views/member_editor_screen.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

const List<double> _tilts = <double>[-0.8, 1, -0.4, 0.7, -1.1, 0.5, -0.3];

/// Раздел «Семья»: карточки участников, по нажатию открывается профиль.
class FamilySection extends ConsumerStatefulWidget {
  const FamilySection({
    super.key,
    required this.family,
    required this.onMemberTap,
  });

  final FamilyData family;
  final ValueChanged<FamilyMember> onMemberTap;

  @override
  ConsumerState<FamilySection> createState() => _FamilySectionState();
}

class _FamilySectionState extends ConsumerState<FamilySection> {
  String? _pinnedMemberId;
  String? _highlightedMemberId;
  Timer? _highlightTimer;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _pinMember(FamilyMember member) {
    _highlightTimer?.cancel();
    setState(() {
      _pinnedMemberId = member.id;
      _highlightedMemberId = member.id;
    });
    _highlightTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() => _highlightedMemberId = null);
    });
  }

  Future<void> _addMember() async {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().toIso8601String().split('T').first;
    final member = FamilyMember(
      id: 'member-${DateTime.now().millisecondsSinceEpoch}',
      role: l10n.memberDefaultRole,
      name: l10n.memberDefaultName,
      nickname: '',
      birthday: today,
      showBirthdayOnTimeline: true,
      about: '',
      accent: '#6b7352',
    );
    ref.read(familyDataProvider.notifier).addMember(member);
    final account = ref.read(currentAccountProvider);
    if (account != null) {
      ref
          .read(accountsProvider.notifier)
          .grantMemberVisibility(account.id, member.id);
    }
    _pinMember(member);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.memberAdded)),
    );
    await _openEditor(member);
  }

  Future<void> _openEditor(FamilyMember member) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MemberEditorScreen(memberId: member.id),
      ),
    );
  }

  List<FamilyMember> _orderedMembers() {
    final members = [...widget.family.members];
    final pinned = _pinnedMemberId;
    if (pinned != null) {
      final index = members.indexWhere((member) => member.id == pinned);
      if (index > 0) members.insert(0, members.removeAt(index));
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editMode = ref.watch(editModeProvider);
    final members = _orderedMembers();

    // Подзаголовок читаем из настроек, чтобы он менялся сразу после правки,
    // не дожидаясь повторной загрузки архива.
    final subtitle = ref.watch(familySettingsProvider).value?.familySubtitle ??
        widget.family.settings.familySubtitle;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      children: [
        PageHero(
          eyebrow: subtitle,
          title: l10n.familyTitle,
          lede: l10n.familyLede,
        ),
        if (editMode) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _addMember,
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.memberAdd),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (members.isEmpty)
          PaperCard(child: Text(l10n.familyEmpty))
        else
          for (var index = 0; index < members.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _MemberCard(
                member: members[index],
                tilt: _tilts[index % _tilts.length],
                editMode: editMode,
                highlighted: _highlightedMemberId == members[index].id,
                onTap: () => editMode
                    ? _openEditor(members[index])
                    : widget.onMemberTap(members[index]),
                onEdit: () => _openEditor(members[index]),
              ),
            ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.tilt,
    required this.editMode,
    required this.highlighted,
    required this.onTap,
    required this.onEdit,
  });

  final FamilyMember member;
  final double tilt;
  final bool editMode;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget card = PaperCard(
      tilt: tilt,
      onTap: onTap,
      child: Row(
        children: [
          MemberAvatar(member: member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.role.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSoft,
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(member.name, style: theme.textTheme.headlineSmall),
                if (member.nickname.trim().isNotEmpty)
                  Text(
                    member.nickname,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      color: AppColors.terracotta,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(_memberMeta(member, l10n),
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.inkSoft),
        ],
      ),
    );

    if (highlighted) {
      card = TweenAnimationBuilder<double>(
        key: ValueKey<String>('member-highlight-${member.id}'),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1600),
        builder: (context, value, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.terracotta.withValues(
                  alpha: 0.3 * (1 - value),
                ),
                blurRadius: 22 * (1 - value) + 4,
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
      clipBehavior: Clip.none,
      children: [
        card,
        if (highlighted)
          Positioned(
            top: 8,
            left: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.eventNewBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        if (editMode)
          Positioned(
            top: 6,
            right: 6,
            child: Tooltip(
              message: l10n.memberEdit,
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
    );
  }
}

String _memberMeta(FamilyMember member, AppLocalizations l10n) {
  final birthday = member.birthdayDate;
  if (birthday == null) return member.birthday;

  final date = DateFormat.MMMMd(l10n.localeName).format(birthday);
  final age = _age(member);
  return age == null ? date : '${l10n.memberAgeYears(age)} · $date';
}

int? _age(FamilyMember member) {
  final birthday = member.birthdayDate;
  if (birthday == null) return null;

  final now = DateTime.now();
  var years = now.year - birthday.year;
  if (now.isBefore(DateTime(now.year, birthday.month, birthday.day))) {
    years -= 1;
  }
  return years < 0 ? null : years;
}
