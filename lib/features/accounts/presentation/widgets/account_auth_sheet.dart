import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/server_auth_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/widgets/accounts_panel.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_attach.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Вход по логину и паролю с откатом к локальной копии аккаунта.
Future<Account?> signInAccount(
  WidgetRef ref,
  String login,
  String password,
) async {
  final serverAuth = ref.read(serverAuthProvider.notifier);
  final outcome = await serverAuth.signIn(login, password);
  if (outcome.isSuccess) {
    ref.read(currentAccountIdProvider.notifier).setAccount(outcome.account!.id);
    return outcome.account;
  }

  final canTryLocal = outcome.status == ServerSignInStatus.accountNotFound ||
      outcome.status == ServerSignInStatus.unavailable;
  if (!canTryLocal) return null;

  final local =
      ref.read(accountsProvider.notifier).authenticate(login, password);
  if (local == null) return null;

  final migrated = await serverAuth.claimLocal(local, password);
  final account = migrated.isSuccess ? migrated.account : local;
  if (account == null) return null;

  ref.read(currentAccountIdProvider.notifier).setAccount(account.id);
  return account;
}

/// Выход из текущего аккаунта: серверный или локальный.
Future<void> signOutAccount(WidgetRef ref) async {
  final account = ref.read(currentAccountProvider);
  if (account == null) return;
  if (account.serverBacked) {
    await ref.read(serverAuthProvider.notifier).signOut();
  } else {
    ref.read(currentAccountIdProvider.notifier).signOut();
  }
}

Future<void> showAccountAuthSheet(BuildContext context) {
  return showCardSheet(context, (sheetContext) => const AccountAuthSheet());
}

Future<void> showAccountSessionSheet(BuildContext context) {
  return showCardSheet(
    context,
    (sheetContext) => AccountSessionSheet(hostContext: context),
  );
}

class AccountAuthSheet extends ConsumerStatefulWidget {
  const AccountAuthSheet({super.key});

  @override
  ConsumerState<AccountAuthSheet> createState() => _AccountAuthSheetState();
}

enum _AuthMode { signIn, signUp }

class _AccountAuthSheetState extends ConsumerState<AccountAuthSheet> {
  final TextEditingController _login = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final login = _login.text.trim();
    final password = _password.text;
    if (login.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.accountLoginFailed);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    Account? account;
    if (_mode == _AuthMode.signIn) {
      account = await signInAccount(ref, login, password);
    } else {
      final input = AccountInput(
        login: login,
        name: _name.text.trim().isEmpty ? login : _name.text.trim(),
        password: password,
        role: UserRole.viewer,
      );

      var error = await ref.read(serverAuthProvider.notifier).create(input);
      if (error == AccountsError.offline) {
        error = ref.read(accountsProvider.notifier).create(input);
      }
      if (error != null) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = accountErrorLabel(error!, l10n);
        });
        return;
      }
      account = await signInAccount(ref, login, password);
    }

    if (!mounted) return;
    if (account == null) {
      setState(() {
        _busy = false;
        _error = l10n.accountLoginFailed;
      });
      return;
    }

    final wasSignIn = _mode == _AuthMode.signIn;
    // Дожидаемся семейного архива, чтобы данные появились сразу после входа,
    // а не после ручного перезапуска.
    final hasFamily = await attachFamilyAfterSignIn(ref);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          wasSignIn
              ? (hasFamily == false
                  ? '${l10n.accountSignedIn(account.name)}\n'
                      '${l10n.accountNoFamilyAttached}'
                  : l10n.accountSignedIn(account.name))
              : l10n.accountCreated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isSignIn = _mode == _AuthMode.signIn;
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.accountAuthTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          isSignIn ? l10n.accountSignInSubtitle : l10n.accountSignUpHint,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        SegmentedButton<_AuthMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: _AuthMode.signIn,
              label: Text(l10n.accountSignInTab),
            ),
            ButtonSegment(
              value: _AuthMode.signUp,
              label: Text(l10n.accountSignUpTab),
            ),
          ],
          selected: <_AuthMode>{_mode},
          onSelectionChanged: _busy
              ? null
              : (selection) => setState(() {
                    _mode = selection.first;
                    _error = null;
                  }),
        ),
        const SizedBox(height: 14),
        _AccountField(
          label: l10n.accountLoginField,
          controller: _login,
          hint: l10n.accountLoginRequirements,
        ),
        if (!isSignIn)
          _AccountField(
            label: l10n.accountNameField,
            controller: _name,
          ),
        _AccountField(
          label: l10n.accountPasswordField,
          controller: _password,
          obscure: true,
          hint: l10n.accountPasswordRequirements,
        ),
        if (!isSignIn && accounts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l10n.accountFirstAdminHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.terracotta,
              ),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.terracotta,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: Icon(isSignIn ? Icons.login : Icons.person_add_alt_1),
            label: Text(
              isSignIn ? l10n.accountSignInAction : l10n.accountCreate,
            ),
          ),
        ),
      ],
    );
  }
}

class AccountSessionSheet extends ConsumerWidget {
  const AccountSessionSheet({super.key, required this.hostContext});

  /// Контекст страницы, с которой открыт лист. После `pop` листа именно он
  /// нужен для показа следующего диалога и SnackBar.
  final BuildContext hostContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final account = ref.watch(currentAccountProvider);
    final role = ref.watch(currentRoleProvider);

    if (account == null) {
      return const AccountAuthSheet();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.accountEntryTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.accountSessionTitle(account.name),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${account.login} · ${roleLabel(role, l10n)}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final host = hostContext;
              await signOutAccount(ref);
              if (!host.mounted) return;
              Navigator.of(context).pop();
              await showAccountAuthSheet(host);
            },
            icon: const Icon(Icons.swap_horiz),
            label: Text(l10n.accountSwitch),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () async {
              final host = hostContext;
              final messenger = ScaffoldMessenger.of(host);
              await signOutAccount(ref);
              if (!host.mounted) return;
              Navigator.of(context).pop();
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.accountSignedOut)),
              );
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.accountSignOut),
          ),
        ),
      ],
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: settingsCaptionStyle(theme),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: settingsInputDecoration(
              hint: hint ?? label,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}
