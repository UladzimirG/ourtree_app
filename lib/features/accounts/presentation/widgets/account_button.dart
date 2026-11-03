import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/widgets/header_action_button.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/widgets/account_auth_sheet.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Кнопка входа/текущего аккаунта. Показывается в шапках всех основных экранов.
class AccountButton extends ConsumerWidget {
  const AccountButton({super.key, this.showLabel = false});

  /// На широких экранах можно показать текст «Войти» или имя аккаунта.
  final bool showLabel;

  void _open(BuildContext context, WidgetRef ref) {
    if (ref.read(currentAccountProvider) == null) {
      showAccountAuthSheet(context);
    } else {
      showAccountSessionSheet(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final account = ref.watch(currentAccountProvider);
    // На узком экране текст «Войти»/имя не помещается в шапку — оставляем
    // компактную иконку с подсказкой.
    final withLabel = showLabel && MediaQuery.sizeOf(context).width >= 520;

    if (!withLabel) {
      return HeaderActionButton(
        icon: account == null ? Icons.login : Icons.person_outline,
        tooltip: account == null ? l10n.accountSignIn : l10n.accountEntryTitle,
        onTap: () => _open(context, ref),
      );
    }

    final label = account == null ? l10n.accountSignIn : account.name;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: TextButton.icon(
        onPressed: () => _open(context, ref),
        style: TextButton.styleFrom(
          foregroundColor:
              account == null ? AppColors.inkSoft : AppColors.terracotta,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        icon: Icon(
          account == null ? Icons.login : Icons.person_outline,
          size: 20,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
