import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';

/// Изменяемый список учётных записей семейного альбома.
///
/// Пока серверного API нет, записи живут в памяти приложения — так же, как
/// остальные правки из раздела настроек. Когда появится API, методы нотифаера
/// останутся прежними, изменится только источник данных.
final accountsNotifierProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async => const <Account>[];

  /// Создаёт аккаунт. Возвращает `null` при успехе или код ошибки.
  AccountsError? create(AccountInput input) {
    final login = input.login.trim().toLowerCase();
    final password = input.password;

    if (!accountLoginPattern.hasMatch(login)) {
      return AccountsError.badLogin;
    }
    if (password.length < accountMinPasswordLength) {
      return AccountsError.weakPassword;
    }
    if (_accounts.any((account) => account.login.toLowerCase() == login)) {
      return AccountsError.loginTaken;
    }

    final account = Account(
      id: _newId('account'),
      login: login,
      name: input.name.trim().isEmpty ? login : input.name.trim(),
      role: input.role,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _set([..._accounts, account]);
    return null;
  }

  /// Обновляет имя, роль и/или пароль. Возвращает `null` при успехе.
  ///
  /// Имя отличается от `AsyncNotifierBase.update`, чтобы не перекрывать
  /// встроенный метод обновления состояния нотифаера.
  AccountsError? updateAccount(String id, AccountPatch patch) {
    final index = _accounts.indexWhere((account) => account.id == id);
    if (index < 0) return AccountsError.notFound;

    if (patch.password != null &&
        patch.password!.length < accountMinPasswordLength) {
      return AccountsError.weakPassword;
    }

    final current = _accounts[index];
    final trimmedName = patch.name?.trim();
    final updated = current.copyWith(
      name: trimmedName == null || trimmedName.isEmpty ? null : trimmedName,
      role: patch.role,
    );
    // Пароль в Account не хранится: в локальном режиме он не нужен, а при
    // подключении API уйдёт отдельным защищённым запросом.
    _set([
      for (var i = 0; i < _accounts.length; i++)
        if (i == index) updated else _accounts[i],
    ]);
    return null;
  }

  void remove(String id) {
    _set(
      _accounts
          .where((account) => account.id != id)
          .toList(growable: false),
    );
  }

  List<Account> get _accounts => state.valueOrNull ?? const <Account>[];

  void _set(List<Account> accounts) {
    state = AsyncData(List<Account>.unmodifiable(accounts));
  }
}

/// Гостевые ссылки, выпущенные для просмотра альбома без аккаунта.
final guestLinksNotifierProvider =
    AsyncNotifierProvider<GuestLinksNotifier, List<GuestLink>>(
  GuestLinksNotifier.new,
);

class GuestLinksNotifier extends AsyncNotifier<List<GuestLink>> {
  @override
  Future<List<GuestLink>> build() async => const <GuestLink>[];

  /// Выпускает ссылку и возвращает её вместе с одноразовым токеном.
  CreatedGuestLink create(GuestLinkInput input) {
    final now = DateTime.now();
    final days = input.days <= 0 ? guestLinkDefaultTtlDays : input.days;
    final link = GuestLink(
      id: _newId('guest'),
      label: input.label.trim(),
      createdAt: now.millisecondsSinceEpoch,
      expiresAt: now.add(Duration(days: days)).millisecondsSinceEpoch,
    );
    _set([link, ..._links]);
    return CreatedGuestLink(link: link, token: _token(link.id));
  }

  void revoke(String id) {
    _set([
      for (final link in _links)
        if (link.id == id) link.copyWith(revoked: true) else link,
    ]);
  }

  void remove(String id) {
    _set(
      _links.where((link) => link.id != id).toList(growable: false),
    );
  }

  List<GuestLink> get _links => state.valueOrNull ?? const <GuestLink>[];

  void _set(List<GuestLink> links) {
    state = AsyncData(List<GuestLink>.unmodifiable(links));
  }
}

String _newId(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

/// Детерминированный демонстрационный токен: в реальном API его выдаёт сервер.
String _token(String linkId) {
  return linkId.replaceFirst('guest-', 'gt-');
}
