import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/domain/models/family_join_exception.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Подключение устройства к облачной семье.
///
/// Пока семья не выбрана, приложение работает с локальным демо-архивом —
/// этот экран и есть точка перехода на общие данные в Firestore.
class FamilyCloudPanel extends ConsumerStatefulWidget {
  const FamilyCloudPanel({super.key});

  @override
  ConsumerState<FamilyCloudPanel> createState() => _FamilyCloudPanelState();
}

class _FamilyCloudPanelState extends ConsumerState<FamilyCloudPanel> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _busy = false;
  String? _inviteCode;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(activeFamilyControllerProvider);

    if (familyAsync.isLoading && !familyAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    if (familyAsync.hasError && !familyAsync.hasValue) {
      // В UI — локализованный текст, в консоль — причина (permission-denied,
      // network, отключённый Anonymous provider и т.п.).
      debugPrint('Семья не загружена: ${familyAsync.error}');
      return _StatusView(
        icon: Icons.cloud_off,
        message: _l10n.familyCloudError,
        actionLabel: _l10n.familyCloudRetry,
        onAction: () =>
            ref.read(activeFamilyControllerProvider.notifier).retry(),
      );
    }

    final family = familyAsync.value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(
          _l10n.familyCloudHint,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        if (family == null) ..._buildSetup() else _buildFamily(family),
      ],
    );
  }

  List<Widget> _buildSetup() {
    final theme = Theme.of(context);
    return [
      PaperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.familyCloudCreateTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: _l10n.familyCloudNameLabel,
                hintText: _l10n.familyCloudNameHint,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _create,
              icon: const Icon(Icons.cloud_done_outlined),
              label: Text(_l10n.familyCloudCreateAction),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      PaperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.familyCloudJoinTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: _l10n.familyCloudCodeLabel,
                hintText: _l10n.familyCloudCodeHint,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _join,
              icon: const Icon(Icons.login),
              label: Text(_l10n.familyCloudJoinAction),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildFamily(FamilyModel family) {
    final theme = Theme.of(context);
    final identity = ref.watch(identityControllerProvider).value;
    final isOwner = identity != null && family.ownerAuthUid == identity.authUid;
    final premium = family.premiumActiveAt(DateTime.now());

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(family.name, style: theme.textTheme.titleMedium),
              ),
              if (isOwner)
                Chip(label: Text(_l10n.familyCloudOwnerBadge)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            premium
                ? _l10n.familyCloudPremiumActive
                : _l10n.familyCloudPremiumFree,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _l10n.familyCloudId(family.id),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSoft,
            ),
          ),
          const Divider(height: 24),
          Text(_l10n.familyCloudInviteTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            _l10n.familyCloudInviteHint,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
          if (_inviteCode != null) ...[
            const SizedBox(height: 10),
            SelectableText(
              _inviteCode!,
              style: theme.textTheme.titleLarge?.copyWith(
                letterSpacing: 4,
                color: AppColors.terracotta,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _createInvite,
                icon: const Icon(Icons.vpn_key_outlined),
                label: Text(_l10n.familyCloudInviteCreate),
              ),
              if (_inviteCode != null)
                OutlinedButton.icon(
                  onPressed: _copyInvite,
                  icon: const Icon(Icons.copy_all_outlined),
                  label: Text(_l10n.familyCloudInviteCopied),
                ),
            ],
          ),
          const Divider(height: 24),
          Text(
            _l10n.familyCloudPrivacyTitle,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _l10n.familyCloudPrivacyHint,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _disconnect,
                icon: const Icon(Icons.logout),
                label: Text(_l10n.familyCloudDisconnect),
              ),
              if (isOwner)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _busy ? null : _deleteCloudData,
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: Text(_l10n.familyCloudDeleteCloud),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect() async {
    final l10n = _l10n;
    final confirmed = await _confirm(
      title: l10n.familyCloudDisconnect,
      message: l10n.familyCloudDisconnectConfirm,
      actionLabel: l10n.familyCloudDisconnect,
    );
    if (!confirmed) return;

    await _run(() async {
      final done =
          await ref.read(activeFamilyControllerProvider.notifier).disconnect();
      if (!mounted) return;
      _showMessage(
        done
            ? l10n.familyCloudDisconnected
            : l10n.familyCloudDisconnectOwnerBlocked,
      );
    });
  }

  Future<void> _deleteCloudData() async {
    final l10n = _l10n;
    final confirmed = await _confirm(
      title: l10n.familyCloudDeleteCloud,
      message: l10n.familyCloudDeleteCloudConfirm,
      actionLabel: l10n.commonDelete,
    );
    if (!confirmed) return;

    await _run(() async {
      await ref.read(activeFamilyControllerProvider.notifier).deleteFamilyData();
      if (!mounted) return;
      _showMessage(l10n.familyCloudDeleteCloudDone);
    });
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage(_l10n.familyCloudNameRequired);
      return;
    }

    await _run(() async {
      await ref.read(activeFamilyControllerProvider.notifier).create(name);
      if (!mounted) return;
      _showMessage(_l10n.familyCloudCreated);
    });
  }

  Future<void> _join() async {
    final raw = _codeController.text;
    await _run(() async {
      try {
        await ref.read(activeFamilyControllerProvider.notifier).join(raw);
        if (!mounted) return;
        _showMessage(_l10n.familyCloudJoined);
      } on InvalidInviteCodeException {
        _showMessage(_l10n.familyCloudInvalidCode);
      } on InviteNotFoundException {
        _showMessage(_l10n.familyCloudJoinNotFound);
      }
    });
  }

  Future<void> _createInvite() async {
    await _run(() async {
      final code = await ref
          .read(activeFamilyControllerProvider.notifier)
          .createInvite();
      if (!mounted) return;
      setState(() => _inviteCode = code);
    });
  }

  Future<void> _copyInvite() async {
    final code = _inviteCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _showMessage(_l10n.familyCloudInviteCopied);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) _showMessage(_l10n.familyCloudError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Состояние «нет данных» с кнопкой действия.
class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.inkSoft),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
