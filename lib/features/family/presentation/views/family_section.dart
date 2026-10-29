import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/widgets/page_hero.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/widgets/member_avatar.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

const List<double> _tilts = <double>[-0.8, 1, -0.4, 0.7, -1.1, 0.5, -0.3];

/// Раздел «Семья»: карточки участников, по нажатию открывается профиль.
class FamilySection extends ConsumerWidget {
  const FamilySection({
    super.key,
    required this.family,
    required this.onMemberTap,
  });

  final FamilyData family;
  final ValueChanged<FamilyMember> onMemberTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final members = family.members;

    // Подзаголовок читаем из настроек, чтобы он менялся сразу после правки,
    // не дожидаясь повторной загрузки архива.
    final subtitle = ref.watch(familySettingsProvider).value?.familySubtitle ??
        family.settings.familySubtitle;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      children: [
        PageHero(
          eyebrow: subtitle,
          title: l10n.familyTitle,
          lede: l10n.familyLede,
        ),
        if (members.isEmpty)
          PaperCard(child: Text(l10n.familyEmpty))
        else
          for (var index = 0; index < members.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PaperCard(
                tilt: _tilts[index % _tilts.length],
                onTap: () => onMemberTap(members[index]),
                child: Row(
                  children: [
                    MemberAvatar(member: members[index]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            members[index].role.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.inkSoft,
                              fontSize: 11,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            members[index].name,
                            style: theme.textTheme.headlineSmall,
                          ),
                          if (members[index].nickname.trim().isNotEmpty)
                            Text(
                              members[index].nickname,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                                color: AppColors.terracotta,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            _memberMeta(members[index], l10n),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.inkSoft,
                    ),
                  ],
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
