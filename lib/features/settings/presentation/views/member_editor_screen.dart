import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/editor_top_bar.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/member_editor_card.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Полноэкранный редактор участника, открываемый из семьи и профиля.
class MemberEditorScreen extends ConsumerWidget {
  const MemberEditorScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final family = ref.watch(familyDataProvider).value;
    final member = family?.memberById(memberId);

    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: family == null || member == null
              ? Center(
                  child:
                      Text(l10n.profileNotFound, textAlign: TextAlign.center),
                )
              : Column(
                  children: [
                    EditorTopBar(
                      title: l10n.memberEditorTitle,
                      doneLabel: l10n.editModeDone,
                      onDone: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                        children: [
                          MemberEditorCard(
                            member: member,
                            members: family.members,
                            events: family.timelineEvents,
                            l10n: l10n,
                            initiallyExpanded: true,
                            canDelete: ref.watch(currentRoleProvider) ==
                                UserRole.admin,
                            onChanged: (updated) => ref
                                .read(familyDataProvider.notifier)
                                .updateMember(updated.id, (_) => updated),
                            onRemove: () => _confirmRemove(
                              context,
                              ref,
                              l10n,
                              member,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FamilyMember member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.memberDeleteConfirmTitle),
        content: Text(l10n.memberDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.memberDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(familyDataProvider.notifier).removeMember(member.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}
