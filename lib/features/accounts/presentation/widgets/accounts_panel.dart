import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Управление аккаунтами и гостевыми ссылками из настроек.
class AccountsPanel extends ConsumerWidget {
  const AccountsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsNotifierProvider).valueOrNull ??
        const <Account>[];
    final links = ref.watch(guestLinksNotifierProvider).valueOrNull ??
        const <GuestLink>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(
          l10n.settingsAccountsHint,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _AccountCreateForm(l10n: l10n),
        const SizedBox(height: 16),
        if (accounts.isEmpty)
          PaperCard(
            tilt: 0.3,
            child: Text(
              l10n.accountsEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        else
          for (final account in accounts) ...[
            _AccountEditorCard(account: account, l10n: l10n),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 8),
        _GuestLinksCard(links: links, l10n: l10n),
        const SizedBox(height: 14),
        Text(
          l10n.settingsAccountsLocalOnly,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AccountCreateForm extends ConsumerStatefulWidget {
  const _AccountCreateForm({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_AccountCreateForm> createState() => _AccountCreateFormState();
}

class _AccountCreateFormState extends ConsumerState<_AccountCreateForm> {
  final TextEditingController _login = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  UserRole _role = UserRole.viewer;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = widget.l10n;
    final error = ref.read(accountsNotifierProvider.notifier).create(
          AccountInput(
            login: _login.text,
            name: _name.text,
            password: _password.text,
            role: _role,
          ),
        );

    if (error != null) {
      setState(() => _error = accountErrorLabel(error, l10n));
      return;
    }

    setState(() {
      _error = null;
      _role = UserRole.viewer;
    });
    _login.clear();
    _name.clear();
    _password.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.accountCreated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return PaperCard(
      tilt: -0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountAdd, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _LabeledField(
            caption: l10n.accountLoginField,
            controller: _login,
            hint: 'family.member',
          ),
          _LabeledField(
            caption: l10n.accountNameField,
            controller: _name,
          ),
          _LabeledField(
            caption: l10n.accountPasswordField,
            controller: _password,
            obscure: true,
          ),
          _RolePicker(
            label: l10n.accountRoleField,
            role: _role,
            l10n: l10n,
            onChanged: (role) => setState(() => _role = role),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.terracotta),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.accountCreate),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountEditorCard extends ConsumerStatefulWidget {
  const _AccountEditorCard({required this.account, required this.l10n});

  final Account account;
  final AppLocalizations l10n;

  @override
  ConsumerState<_AccountEditorCard> createState() => _AccountEditorCardState();
}

class _AccountEditorCardState extends ConsumerState<_AccountEditorCard> {
  late final TextEditingController _name;
  final TextEditingController _password = TextEditingController();
  late UserRole _role;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.account.name);
    _role = widget.account.role;
  }

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  void _save() {
    final error = ref.read(accountsNotifierProvider.notifier).updateAccount(
          widget.account.id,
          AccountPatch(
            name: _name.text,
            role: _role,
            password: _password.text.isEmpty ? null : _password.text,
          ),
        );
    if (error != null) {
      setState(() => _error = accountErrorLabel(error, widget.l10n));
      return;
    }
    _password.clear();
    setState(() => _error = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.l10n.accountSaved)),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = widget.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.accountDeleteConfirmTitle),
        content: Text(l10n.accountDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.accountDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    ref.read(accountsNotifierProvider.notifier).remove(widget.account.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.accountDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return PaperCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: AppColors.kraftWash,
          child: Icon(
            widget.account.isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            color: AppColors.moss,
          ),
        ),
        title: Text(widget.account.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${widget.account.login} · ${roleLabel(widget.account.role, l10n)}',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          SettingsTextField(
            label: l10n.accountNameField,
            initialValue: widget.account.name,
            onChanged: (value) => _name.text = value,
          ),
          _LabeledField(
            caption: l10n.accountPasswordField,
            controller: _password,
            hint: l10n.accountPasswordKeepHint,
            obscure: true,
          ),
          _RolePicker(
            label: l10n.accountRoleField,
            role: _role,
            l10n: l10n,
            onChanged: (role) => setState(() => _role = role),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.terracotta),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.settingsSave),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _confirmDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.accountDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestLinksCard extends ConsumerStatefulWidget {
  const _GuestLinksCard({required this.links, required this.l10n});

  final List<GuestLink> links;
  final AppLocalizations l10n;

  @override
  ConsumerState<_GuestLinksCard> createState() => _GuestLinksCardState();
}

class _GuestLinksCardState extends ConsumerState<_GuestLinksCard> {
  final TextEditingController _label = TextEditingController();
  final TextEditingController _days =
      TextEditingController(text: '$guestLinkDefaultTtlDays');
  String? _freshToken;

  @override
  void dispose() {
    _label.dispose();
    _days.dispose();
    super.dispose();
  }

  void _create() {
    final days = int.tryParse(_days.text.trim()) ?? guestLinkDefaultTtlDays;
    final created = ref.read(guestLinksNotifierProvider.notifier).create(
          GuestLinkInput(label: _label.text, days: days),
        );
    setState(() => _freshToken = created.token);
    _label.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final now = DateTime.now();

    return PaperCard(
      tilt: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.guestLinksTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.guestLinksHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _label,
            decoration:
                settingsInputDecoration(hint: l10n.guestLinkLabelField),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _days,
            keyboardType: TextInputType.number,
            decoration: settingsInputDecoration(hint: l10n.guestLinkDaysField),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.link),
              label: Text(l10n.guestLinkCreate),
            ),
          ),
          if (_freshToken != null) ...[
            const SizedBox(height: 10),
            SelectableText(
              _freshToken!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _freshToken!));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.guestLinkCopied)),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(l10n.guestLinkCopy),
              ),
            ),
          ],
          if (widget.links.isEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.guestLinksEmpty, style: theme.textTheme.bodyMedium),
          ] else ...[
            const SizedBox(height: 8),
            for (final link in widget.links)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  link.isActiveAt(now) ? Icons.link : Icons.link_off,
                  color:
                      link.isActiveAt(now) ? AppColors.moss : AppColors.inkSoft,
                ),
                title: Text(
                  link.label.isEmpty ? link.id : link.label,
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  guestLinkStatus(link, now, l10n),
                  style: theme.textTheme.bodySmall,
                ),
                trailing: link.revoked
                    ? null
                    : TextButton(
                        onPressed: () => ref
                            .read(guestLinksNotifierProvider.notifier)
                            .revoke(link.id),
                        child: Text(l10n.guestLinkRevoke),
                      ),
              ),
          ],
        ],
      ),
    );
  }
}


class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.caption,
    required this.controller,
    this.hint,
    this.obscure = false,
  });

  final String caption;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption.toUpperCase(),
            style: settingsCaptionStyle(Theme.of(context)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: settingsInputDecoration(hint: hint ?? caption),
          ),
        ],
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({
    required this.label,
    required this.role,
    required this.l10n,
    required this.onChanged,
  });

  final String label;
  final UserRole role;
  final AppLocalizations l10n;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: settingsCaptionStyle(Theme.of(context)),
            ),
          ),
          DropdownButton<UserRole>(
            value: role,
            items: [
              for (final option in UserRole.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(roleLabel(option, l10n)),
                ),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

String roleLabel(UserRole role, AppLocalizations l10n) {
  return switch (role) {
    UserRole.viewer => l10n.accountRoleViewer,
    UserRole.editor => l10n.accountRoleEditor,
    UserRole.admin => l10n.accountRoleAdmin,
  };
}

String accountErrorLabel(AccountsError error, AppLocalizations l10n) {
  return switch (error) {
    AccountsError.badLogin => l10n.accountLoginInvalid,
    AccountsError.badRole => l10n.accountRoleInvalid,
    AccountsError.weakPassword => l10n.accountPasswordTooShort,
    AccountsError.loginTaken => l10n.accountLoginTaken,
    AccountsError.cannotDeleteSelf => l10n.accountCannotDeleteSelf,
    AccountsError.cannotChangeOwnRole => l10n.accountCannotChangeOwnRole,
    AccountsError.notFound => l10n.accountNotFound,
    AccountsError.forbidden => l10n.accountForbidden,
    AccountsError.unauthenticated => l10n.accountUnauthenticated,
    AccountsError.offline => l10n.accountOffline,
    AccountsError.unknown => l10n.accountUnknownError,
  };
}

String guestLinkStatus(GuestLink link, DateTime now, AppLocalizations l10n) {
  if (link.revoked) return l10n.guestLinkStatusRevoked;
  if (link.isExpiredAt(now)) return l10n.guestLinkStatusExpired;
  return l10n.guestLinkStatusActive;
}

