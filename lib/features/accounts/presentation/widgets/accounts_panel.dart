import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/server_auth_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_attach.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Управление аккаунтами и гостевыми ссылками из настроек.
class AccountsPanel extends ConsumerWidget {
  const AccountsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final role = ref.watch(currentRoleProvider);
    if (role != UserRole.admin) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.settingsNoAccess, textAlign: TextAlign.center),
        ),
      );
    }
    final accountsAsync = ref.watch(accountsProvider);
    if (accountsAsync.isLoading && !accountsAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    final accounts = accountsAsync.value ?? const <Account>[];
    final links = ref.watch(guestLinksProvider).value ?? const <GuestLink>[];
    final family = ref.watch(familyDataProvider).value;

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
            _AccountEditorCard(
              account: account,
              family: family,
              l10n: l10n,
            ),
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
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = widget.l10n;
    final input = AccountInput(
      login: _login.text,
      name: _name.text,
      password: _password.text,
      role: _role,
    );

    setState(() {
      _busy = true;
      _error = null;
    });

    var error = await ref.read(serverAuthProvider.notifier).create(input);
    if (!mounted) return;

    // Сервер недоступен: сохраняем локальную копию, чтобы приложение
    // продолжало работать без сети. При первом успешном входе она
    // перенесётся на сервер автоматически.
    if (error == AccountsError.offline) {
      error = ref.read(accountsProvider.notifier).create(input);
      setState(() {
        _busy = false;
        _error = error == null ? null : accountErrorLabel(error, l10n);
      });
      if (error != null) return;
      _resetFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountCreatedLocalOnly)),
      );
      return;
    }

    setState(() {
      _busy = false;
      _error = error == null ? null : accountErrorLabel(error, l10n);
    });
    if (error != null) return;

    _resetFields();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.accountCreated)),
    );
  }

  void _resetFields() {
    setState(() => _role = UserRole.viewer);
    _login.clear();
    _name.clear();
    _password.clear();
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
            hint: 'ab',
            helper: l10n.accountLoginRequirements,
          ),
          _LabeledField(
            caption: l10n.accountNameField,
            controller: _name,
          ),
          _LabeledField(
            caption: l10n.accountPasswordField,
            controller: _password,
            obscure: true,
            helper: l10n.accountPasswordRequirements,
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
              onPressed: _busy ? null : _submit,
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
  const _AccountEditorCard({
    required this.account,
    required this.family,
    required this.l10n,
  });

  final Account account;
  final FamilyData? family;
  final AppLocalizations l10n;

  @override
  ConsumerState<_AccountEditorCard> createState() => _AccountEditorCardState();
}

class _AccountEditorCardState extends ConsumerState<_AccountEditorCard> {
  late final TextEditingController _name;
  final TextEditingController _password = TextEditingController();
  late UserRole _role;
  String? _error;
  bool _busy = false;

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

  Future<void> _save() async {
    final patch = AccountPatch(
      name: _name.text,
      // Роль отправляем только при изменении: сервер запрещает менять
      // собственную роль, даже если значение совпадает.
      role: _role == widget.account.role ? null : _role,
      password: _password.text.isEmpty ? null : _password.text,
    );

    setState(() {
      _busy = true;
      _error = null;
    });

    AccountsError? error;
    if (widget.account.serverBacked) {
      error = await ref.read(serverAuthProvider.notifier).update(
            widget.account,
            patch,
          );
      if (error == AccountsError.offline) {
        // Нет сети: правим локальную копию, сервер обновится при следующем входе.
        error = ref.read(accountsProvider.notifier).updateAccount(
              widget.account.id,
              patch,
            );
      }
    } else {
      error = ref.read(accountsProvider.notifier).updateAccount(
            widget.account.id,
            patch,
          );
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error == null ? null : accountErrorLabel(error, widget.l10n);
    });
    if (error != null) return;

    _password.clear();
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

    final error =
        await ref.read(serverAuthProvider.notifier).delete(widget.account);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = accountErrorLabel(error, l10n));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.accountDeleted)),
    );
  }

  void _setAccess({
    required bool allMembersVisible,
    required List<String> visibleMemberIds,
  }) {
    ref.read(accountsProvider.notifier).updateAccess(
          widget.account.id,
          allMembersVisible: allMembersVisible,
          visibleMemberIds: visibleMemberIds,
        );
    if (widget.account.serverBacked) {
      unawaited(
        ref.read(serverAuthProvider.notifier).updateAccess(
              widget.account.id,
              allMembersVisible: allMembersVisible,
              visibleMemberIds: visibleMemberIds,
            ),
      );
    }
  }

  void _toggleMember(String memberId, bool selected) {
    final ids = [...widget.account.visibleMemberIds];
    if (selected) {
      if (!ids.contains(memberId)) ids.add(memberId);
    } else {
      ids.remove(memberId);
    }
    _setAccess(
      allMembersVisible: widget.account.allMembersVisible,
      visibleMemberIds: ids,
    );
  }

  void _toggleEvent(TimelineEvent event, bool visible) {
    final hidden = [...event.hiddenFrom];
    if (visible) {
      hidden.remove(widget.account.id);
    } else if (!hidden.contains(widget.account.id)) {
      hidden.add(widget.account.id);
    }
    ref.read(familyDataProvider.notifier).updateTimelineEvent(
          event.id,
          (_) => event.copyWith(hiddenFrom: hidden),
        );
  }

  List<Widget> _accessSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final family = widget.family;
    if (family == null) return const <Widget>[];
    final theme = Theme.of(context);
    final account = widget.account;

    return [
      const Divider(height: 24),
      Text(l10n.accountAccessTitle, style: theme.textTheme.titleSmall),
      const SizedBox(height: 4),
      Text(l10n.accountAccessHint, style: theme.textTheme.bodySmall),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: account.allMembersVisible,
        title: Text(l10n.accountAllMembers),
        onChanged: account.isAdmin
            ? null
            : (value) => _setAccess(
                  allMembersVisible: value,
                  visibleMemberIds: account.visibleMemberIds,
                ),
      ),
      if (!account.allMembersVisible && !account.isAdmin)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final member in family.members)
              FilterChip(
                label: Text(
                  member.name.trim().isEmpty ? '—' : member.name,
                ),
                selected: account.visibleMemberIds.contains(member.id),
                onSelected: (selected) => _toggleMember(member.id, selected),
              ),
          ],
        ),
      const SizedBox(height: 10),
      Text(l10n.accountVisibleEvents, style: theme.textTheme.titleSmall),
      for (final event in family.sortedTimelineEvents)
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: !event.hiddenFrom.contains(account.id),
          title: Text(
            event.title.trim().isEmpty ? '—' : event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(event.date),
          onChanged: account.isAdmin
              ? null
              : (value) {
                  if (value != null) _toggleEvent(event, value);
                },
        ),
    ];
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
          '${widget.account.login} · ${roleLabel(widget.account.role, l10n)}'
          '${widget.account.serverBacked ? ' · ${l10n.accountServerBadge}' : ''}',
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
          ..._accessSection(context, l10n),
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
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.settingsSave),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _busy ? null : _confirmDelete,
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
    final created = ref.read(guestLinksProvider.notifier).create(
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
            decoration: settingsInputDecoration(hint: l10n.guestLinkLabelField),
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
                            .read(guestLinksProvider.notifier)
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
    this.helper,
    this.obscure = false,
  });

  final String caption;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
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
            decoration: settingsInputDecoration(
              hint: hint ?? caption,
              helper: helper,
            ),
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

/// Строка текущего пользователя и вход/выход из локального аккаунта.
class AccountSessionBar extends ConsumerWidget {
  const AccountSessionBar({super.key});

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final account = await showDialog<Account>(
      context: context,
      builder: (_) => _LoginDialog(l10n: l10n),
    );
    if (account == null) return;
    ref.read(currentAccountIdProvider.notifier).setAccount(account.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.accountSignedIn(account.name))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final account = ref.watch(currentAccountProvider);
    final role = ref.watch(currentRoleProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(
            account?.isAdmin == true
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            size: 18,
            color: AppColors.moss,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              account == null
                  ? '${l10n.accountLocalAdmin} · ${roleLabel(role, l10n)}'
                  : '${account.name} · ${roleLabel(role, l10n)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (account == null)
            TextButton(
              onPressed: () => _signIn(context, ref),
              child: Text(l10n.accountSignIn),
            ),
          if (account != null)
            TextButton(
              onPressed: () async {
                if (account.serverBacked) {
                  await ref.read(serverAuthProvider.notifier).signOut();
                } else {
                  ref.read(currentAccountIdProvider.notifier).signOut();
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.accountSignedOut)),
                );
              },
              child: Text(l10n.accountSignOut),
            ),
        ],
      ),
    );
  }
}

class _LoginDialog extends ConsumerStatefulWidget {
  const _LoginDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<_LoginDialog> {
  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = widget.l10n;
    final login = _login.text;
    final password = _password.text;

    setState(() {
      _busy = true;
      _error = null;
    });

    final serverAuth = ref.read(serverAuthProvider.notifier);
    final outcome = await serverAuth.signIn(login, password);
    if (!mounted) return;

    if (outcome.isSuccess) {
      await attachFamilyAfterSignIn(ref);
      if (!mounted) return;
      Navigator.of(context).pop(outcome.account);
      return;
    }

    // Сервер не нашёл аккаунт или недоступен — проверяем локальную копию.
    // Если пароль верный, переносим аккаунт на сервер (или входим локально,
    // когда сети нет вовсе).
    final canTryLocal = outcome.status == ServerSignInStatus.accountNotFound ||
        outcome.status == ServerSignInStatus.unavailable;
    if (canTryLocal) {
      final local =
          ref.read(accountsProvider.notifier).authenticate(login, password);
      if (local != null) {
        final migrated = await serverAuth.claimLocal(local, password);
        if (!mounted) return;
        if (migrated.isSuccess) {
          await attachFamilyAfterSignIn(ref);
          if (!mounted) return;
          Navigator.of(context).pop(migrated.account);
          return;
        }
        if (migrated.status == ServerSignInStatus.unavailable) {
          // Офлайн-режим: продолжаем с локальной копией.
          ref.read(currentAccountIdProvider.notifier).setAccount(local.id);
          Navigator.of(context).pop(local);
          return;
        }
      }
    }

    setState(() {
      _busy = false;
      _error = switch (outcome.status) {
        ServerSignInStatus.unavailable => l10n.accountServerUnavailable,
        ServerSignInStatus.invalidCredentials ||
        ServerSignInStatus.accountNotFound =>
          l10n.accountLoginFailed,
        ServerSignInStatus.success ||
        ServerSignInStatus.serverError =>
          l10n.accountServerError,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.accountSignIn),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LabeledField(
            caption: l10n.accountLoginField,
            controller: _login,
          ),
          _LabeledField(
            caption: l10n.accountPasswordField,
            controller: _password,
            obscure: true,
          ),
          if (_error != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.terracotta),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(l10n.accountSignInAction),
        ),
      ],
    );
  }
}

String guestLinkStatus(GuestLink link, DateTime now, AppLocalizations l10n) {
  if (link.revoked) return l10n.guestLinkStatusRevoked;
  if (link.isExpiredAt(now)) return l10n.guestLinkStatusExpired;
  return l10n.guestLinkStatusActive;
}
