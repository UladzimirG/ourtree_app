import 'dart:async';
import 'dart:convert';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_provider.g.dart';

/// Ключи локального хранилища аккаунтов и текущей сессии.
const String accountsStorageKey = 'accounts';
const String guestLinksStorageKey = 'guest_links';
const String currentAccountStorageKey = 'current_account_id';

/// Изменяемый список учётных записей семейного альбома.
///
/// Аккаунты и права хранятся в Hive и переживают перезапуск приложения.
@Riverpod(keepAlive: true)
class AccountsNotifier extends _$AccountsNotifier {
  @override
  Future<List<Account>> build() async => _load();

  List<Account> _load() {
    final raw = MediaStorage.instance.getString(accountsStorageKey);
    if (raw == null || raw.trim().isEmpty) return const <Account>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Account>[];
      return [
        for (final item in decoded)
          if (item is Map) Account.fromJson(item.cast<String, dynamic>()),
      ];
    } catch (_) {
      return const <Account>[];
    }
  }

  /// Создаёт аккаунт. Возвращает `null` при успехе или код ошибки.
  AccountsError? create(AccountInput input) {
    // Не создаём аккаунт, пока список ещё загружается: иначе build()
    // может перезаписать добавленную запись старым состоянием.
    if (!state.hasValue) return AccountsError.unknown;

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

    final salt = newPasswordSalt();
    final account = Account(
      id: _newId('account'),
      login: login,
      name: input.name.trim().isEmpty ? login : input.name.trim(),
      role: input.role,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      passwordSalt: salt,
      passwordHash: hashAccountPassword(password, salt),
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
    String? salt;
    String? hash;
    if (patch.password != null) {
      salt = newPasswordSalt();
      hash = hashAccountPassword(patch.password!, salt);
    }
    final updated = current.copyWith(
      name: trimmedName == null || trimmedName.isEmpty ? null : trimmedName,
      role: patch.role,
      passwordSalt: salt,
      passwordHash: hash,
    );
    _set([
      for (var i = 0; i < _accounts.length; i++)
        if (i == index) updated else _accounts[i],
    ]);
    return null;
  }

  /// Меняет видимость профилей, не затрагивая остальные поля аккаунта.
  void updateAccess(
    String id, {
    required bool allMembersVisible,
    required List<String> visibleMemberIds,
  }) {
    final index = _accounts.indexWhere((account) => account.id == id);
    if (index < 0) return;
    _set([
      for (var i = 0; i < _accounts.length; i++)
        if (i == index)
          _accounts[i].copyWith(
            allMembersVisible: allMembersVisible,
            visibleMemberIds: List<String>.unmodifiable(visibleMemberIds),
          )
        else
          _accounts[i],
    ]);
  }

  /// Делает созданный редактором профиль видимым этому редактору.
  void grantMemberVisibility(String accountId, String memberId) {
    final account = _firstOrNull(_accounts, (item) => item.id == accountId);
    if (account == null || account.isAdmin || account.allMembersVisible) return;
    if (account.visibleMemberIds.contains(memberId)) return;
    updateAccess(
      accountId,
      allMembersVisible: false,
      visibleMemberIds: [...account.visibleMemberIds, memberId],
    );
  }

  /// Проверяет логин и пароль; `null`, если данные неверны.
  Account? authenticate(String login, String password) {
    final normalized = login.trim().toLowerCase();
    final account = _firstOrNull(
      _accounts,
      (item) => item.login.toLowerCase() == normalized,
    );
    if (account == null) return null;
    if (!verifyAccountPassword(
      password: password,
      salt: account.passwordSalt,
      hash: account.passwordHash,
    )) {
      return null;
    }
    return account;
  }

  void remove(String id) {
    _set(
      _accounts
          .where((account) => account.id != id)
          .toList(growable: false),
    );
  }

  /// Заменяет список целиком — используется восстановлением из бэкапа.
  void replaceAll(List<Account> accounts) {
    _set(List<Account>.unmodifiable(accounts));
  }

  List<Account> get _accounts => state.value ?? const <Account>[];

  void _set(List<Account> accounts) {
    final next = List<Account>.unmodifiable(accounts);
    state = AsyncData(next);
    unawaited(_persist(next));
  }

  Future<void> _persist(List<Account> accounts) {
    return MediaStorage.instance.putString(
      accountsStorageKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
  }
}

/// Текущий пользователь; `null` — локальный администратор устройства.
@Riverpod(keepAlive: true)
class CurrentAccountId extends _$CurrentAccountId {
  @override
  String? build() => MediaStorage.instance.getString(currentAccountStorageKey);

  void setAccount(String? id) {
    state = id;
    if (id == null || id.isEmpty) {
      unawaited(MediaStorage.instance.removeString(currentAccountStorageKey));
    } else {
      unawaited(
        MediaStorage.instance.putString(currentAccountStorageKey, id),
      );
    }
  }

  void signOut() => setAccount(null);
}

/// Аккаунт, от имени которого сейчас работает интерфейс.
@Riverpod(keepAlive: true)
Account? currentAccount(Ref ref) {
  final id = ref.watch(currentAccountIdProvider);
  if (id == null) return null;
  final accounts =
      ref.watch(accountsProvider).value ?? const <Account>[];
  return _firstOrNull(accounts, (account) => account.id == id);
}

/// Роль текущего пользователя. Локальный владелец устройства — админ.
@Riverpod(keepAlive: true)
UserRole currentRole(Ref ref) =>
    ref.watch(currentAccountProvider)?.role ?? UserRole.admin;

/// Может ли текущий пользователь управлять аккаунтами.
@Riverpod(keepAlive: true)
bool canManageAccounts(Ref ref) => ref.watch(currentRoleProvider) == UserRole.admin;

/// Гостевые ссылки, выпущенные для просмотра альбома без аккаунта.
@Riverpod(keepAlive: true)
class GuestLinksNotifier extends _$GuestLinksNotifier {
  @override
  Future<List<GuestLink>> build() async => _load();

  List<GuestLink> _load() {
    final raw = MediaStorage.instance.getString(guestLinksStorageKey);
    if (raw == null || raw.trim().isEmpty) return const <GuestLink>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <GuestLink>[];
      return [
        for (final item in decoded)
          if (item is Map) GuestLink.fromJson(item.cast<String, dynamic>()),
      ];
    } catch (_) {
      return const <GuestLink>[];
    }
  }

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

  /// Заменяет список целиком — используется восстановлением из бэкапа.
  void replaceAll(List<GuestLink> links) {
    _set(List<GuestLink>.unmodifiable(links));
  }

  List<GuestLink> get _links => state.value ?? const <GuestLink>[];

  void _set(List<GuestLink> links) {
    final next = List<GuestLink>.unmodifiable(links);
    state = AsyncData(next);
    unawaited(_persist(next));
  }

  Future<void> _persist(List<GuestLink> links) {
    return MediaStorage.instance.putString(
      guestLinksStorageKey,
      jsonEncode(links.map((link) => link.toJson()).toList()),
    );
  }
}

T? _firstOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

String _newId(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

/// Детерминированный демонстрационный токен: в реальном API его выдаёт сервер.
String _token(String linkId) {
  return linkId.replaceFirst('guest-', 'gt-');
}
