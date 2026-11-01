import { randomBytes, randomUUID, scryptSync, timingSafeEqual } from 'node:crypto';

import { App, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';

import { FUNCTIONS_REGION } from './region';

/**
 * Серверные аккаунты семьи: логин и пароль проверяются здесь, клиент
 * получает Firebase custom token с `uid == accountId`.
 *
 * Пароли хранятся только как scrypt-хеш с индивидуальной солью. Клиент
 * никогда не видит хеш и не может писать в коллекции `accounts` напрямую —
 * это запрещено правилами Firestore.
 */

type Role = 'admin' | 'editor' | 'viewer';

const ROLES: Role[] = ['admin', 'editor', 'viewer'];
const LOGIN_PATTERN = /^[a-z0-9._-]{2,32}$/;
const ACCOUNT_ID_PATTERN = /^[A-Za-z0-9._-]{4,64}$/;
const MIN_PASSWORD_LENGTH = 4;
const MAX_NAME_LENGTH = 64;
const MAX_VISIBLE_MEMBERS = 500;

const ACCOUNTS = 'accounts';
const LOGINS = 'accountLogins';
const META = 'accountMeta';
const BOOTSTRAP_DOC = 'bootstrap';

interface AccountDoc {
  id: string;
  login: string;
  loginLower: string;
  name: string;
  role: Role;
  createdAt: number;
  allMembersVisible: boolean;
  visibleMemberIds: string[];
  passwordAlgo: 'scrypt';
  passwordSalt: string;
  passwordHash: string;
  authUid: string;
}

/** Ответ клиенту: без хеша, соли и служебных полей. */
interface PublicAccount {
  id: string;
  login: string;
  name: string;
  role: Role;
  createdAt: number;
  allMembersVisible: boolean;
  visibleMemberIds: string[];
  serverBacked: true;
}

function db() {
  return getFirestore(ensureAdminApp());
}

function accounts() {
  return db().collection(ACCOUNTS);
}

function logins() {
  return db().collection(LOGINS);
}

const DEFAULT_APP_NAME = '[DEFAULT]';

/**
 * Возвращает именно default-приложение Admin SDK.
 *
 * `getApps().length !== 0` не гарантирует наличие `[DEFAULT]`: в окружении
 * Cloud Functions может существовать приложение с другим именем. Поэтому
 * ищем по имени и при необходимости создаём default.
 */
function ensureAdminApp(): App {
  const apps = getApps();
  const existing = apps.find((app) => app.name === DEFAULT_APP_NAME);
  if (existing) return existing;
  return initializeApp();
}

function readString(value: unknown, fallback = ''): string {
  return typeof value === 'string' ? value : fallback;
}

function normalizeLogin(raw: unknown): string {
  return readString(raw).trim().toLowerCase();
}

function readRole(raw: unknown): Role | null {
  const value = readString(raw);
  return (ROLES as string[]).includes(value) ? (value as Role) : null;
}

function readVisibleMembers(raw: unknown): string[] | null {
  if (!Array.isArray(raw)) return null;
  const ids = raw
    .filter((item): item is string => typeof item === 'string' && item.length > 0)
    .slice(0, MAX_VISIBLE_MEMBERS);
  return Array.from(new Set(ids));
}

function newSalt(): string {
  return randomBytes(16).toString('base64url');
}

function hashPassword(password: string, salt: string): string {
  // scrypt по умолчанию: N=16384, r=8, p=1.
  return scryptSync(password, salt, 64).toString('base64url');
}

function passwordMatches(
  password: string,
  salt: string,
  expectedHash: string,
): boolean {
  const actual = Buffer.from(hashPassword(password, salt), 'base64url');
  const expected = Buffer.from(expectedHash, 'base64url');
  if (actual.length !== expected.length) return false;
  return timingSafeEqual(actual, expected);
}

function toPublic(account: AccountDoc): PublicAccount {
  return {
    id: account.id,
    login: account.login,
    name: account.name,
    role: account.role,
    createdAt: account.createdAt,
    allMembersVisible: account.allMembersVisible,
    visibleMemberIds: account.visibleMemberIds,
    serverBacked: true,
  };
}

async function accountById(id: string): Promise<AccountDoc | null> {
  if (!id) return null;
  const snapshot = await accounts().doc(id).get();
  const data = snapshot.data();
  if (!data) return null;
  return data as AccountDoc;
}

async function requireAuthUid(request: CallableRequest): Promise<string> {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'account/unauthenticated');
  return uid;
}

/**
 * Создаёт пользователя Firebase с нужным uid, чтобы `auth.uid` совпадал
 * с id аккаунта и переживал переустановку приложения.
 */
async function ensureAuthUser(uid: string, name: string): Promise<void> {
  try {
    await getAuth(ensureAdminApp()).getUser(uid);
  } catch {
    try {
      await getAuth(ensureAdminApp()).createUser({ uid, displayName: name });
    } catch (error) {
      logger.warn('accounts: не удалось создать пользователя Firebase', {
        uid,
        error,
      });
    }
  }
}

/**
 * Переносит членство и владение семьями с прежнего (анонимного) uid на
 * аккаунт. Выполняется в момент входа: клиент ещё авторизован старым uid и
 * одновременно доказал пароль аккаунта, поэтому подмены быть не может.
 */
async function migrateIdentity(oldUid: string, newUid: string): Promise<void> {
  if (!oldUid || oldUid === newUid) return;

  try {
    const families = await db()
      .collection('families')
      .where('memberUids', 'array-contains', oldUid)
      .get();

    for (const family of families.docs) {
      const familyData = family.data();
      const oldMemberRef = family.ref.collection('members').doc(oldUid);
      const oldMember = await oldMemberRef.get();
      const memberData = oldMember.data();

      const batch = db().batch();
      if (memberData) {
        batch.set(
          family.ref.collection('members').doc(newUid),
          {
            ...memberData,
            authUid: newUid,
            userId: newUid,
            status: 'active',
          },
          { merge: true },
        );
        batch.delete(oldMemberRef);
      }

      const memberUids: string[] = Array.isArray(familyData.memberUids)
        ? familyData.memberUids.filter(
            (uid: unknown): uid is string => typeof uid === 'string',
          )
        : [];
      const nextUids = Array.from(
        new Set([...memberUids.filter((uid) => uid !== oldUid), newUid]),
      );

      batch.update(family.ref, {
        memberUids: nextUids,
        ...(familyData.ownerAuthUid === oldUid
          ? { ownerAuthUid: newUid }
          : {}),
      });

      await batch.commit();
    }

    const oldUserRef = db().collection('users').doc(oldUid);
    const oldUser = await oldUserRef.get();
    if (oldUser.exists) {
      const data = oldUser.data() ?? {};
      const batch = db().batch();
      batch.set(
        db().collection('users').doc(newUid),
        { ...data, authUid: newUid, id: newUid },
        { merge: true },
      );
      batch.delete(oldUserRef);
      await batch.commit();
    }

    if (families.size > 0) {
      logger.info('accounts: членство перенесено', {
        oldUid,
        newUid,
        families: families.size,
      });
    }
  } catch (error) {
    // Не блокируем вход: пользователь сможет подключиться по коду заново.
    logger.error('accounts: не удалось перенести членство', {
      oldUid,
      newUid,
      error,
    });
  }
}


/** Регистрация: логин, пароль и роль (роль выдаёт только администратор). */
export const accountRegister = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    ensureAdminApp();

    const input = (request.data ?? {}) as Record<string, unknown>;
    const login = normalizeLogin(input.login);
    const password = readString(input.password);
    const name = readString(input.name).trim() || login;
    const requestedRole = readRole(input.role) ?? 'viewer';

    if (!LOGIN_PATTERN.test(login)) {
      throw new HttpsError('invalid-argument', 'account/bad-login');
    }
    if (password.length < MIN_PASSWORD_LENGTH) {
      throw new HttpsError('invalid-argument', 'account/weak-password');
    }
    if (name.length > MAX_NAME_LENGTH) {
      throw new HttpsError('invalid-argument', 'account/bad-name');
    }

    const requestedId = readString(input.id).trim();
    if (requestedId && !ACCOUNT_ID_PATTERN.test(requestedId)) {
      throw new HttpsError('invalid-argument', 'account/bad-id');
    }
    const accountId = requestedId || `account-${randomUUID()}`;

    const callerUid = request.auth?.uid ?? '';
    const caller = callerUid ? await accountById(callerUid) : null;
    const isCallerAdmin = caller?.role === 'admin';

    const now = Date.now();
    const salt = newSalt();
    const account: AccountDoc = {
      id: accountId,
      login,
      loginLower: login,
      name,
      role: requestedRole,
      createdAt: now,
      allMembersVisible: true,
      visibleMemberIds: [],
      passwordAlgo: 'scrypt',
      passwordSalt: salt,
      passwordHash: hashPassword(password, salt),
      authUid: accountId,
    };

    const created = await db().runTransaction(async (tx) => {
      const accountRef = accounts().doc(accountId);
      const existingAccount = await tx.get(accountRef);
      if (existingAccount.exists) {
        throw new HttpsError('already-exists', 'account/id-taken');
      }

      const loginRef = logins().doc(login);
      const loginSnapshot = await tx.get(loginRef);
      if (loginSnapshot.exists) {
        throw new HttpsError('already-exists', 'account/login-taken');
      }

      const metaRef = db().collection(META).doc(BOOTSTRAP_DOC);
      const metaSnapshot = await tx.get(metaRef);
      const isFirst = !metaSnapshot.exists;

      // Первый зарегистрированный аккаунт становится администратором —
      // иначе управлять ролями было бы некому. Дальше роли выдаёт админ.
      const role: Role = isCallerAdmin
        ? requestedRole
        : isFirst
          ? 'admin'
          : 'viewer';
      const stored: AccountDoc = { ...account, role };

      if (isFirst) {
        tx.set(metaRef, { firstAccountId: accountId, createdAt: now });
      }
      tx.set(accounts().doc(accountId), stored);
      tx.set(loginRef, { accountId, createdAt: now });
      return stored;
    });

    await ensureAuthUser(accountId, created.name);
    logger.info('accounts: создан', { accountId, login });
    return toPublic(created);
  },
);


/** Вход: проверка пароля и выдача custom token для Firebase Auth. */
export const accountLogin = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    ensureAdminApp();

    const input = (request.data ?? {}) as Record<string, unknown>;
    const login = normalizeLogin(input.login);
    const password = readString(input.password);

    const loginSnapshot = await logins().doc(login).get();
    const accountId = readString(loginSnapshot.data()?.accountId);
    if (!accountId) {
      throw new HttpsError('not-found', 'account/not-found');
    }

    const account = await accountById(accountId);
    if (!account) {
      throw new HttpsError('not-found', 'account/not-found');
    }
    if (!passwordMatches(password, account.passwordSalt, account.passwordHash)) {
      throw new HttpsError('permission-denied', 'account/bad-password');
    }

    await ensureAuthUser(account.id, account.name);

    const oldUid = request.auth?.uid ?? '';
    if (oldUid && oldUid !== account.id) {
      await migrateIdentity(oldUid, account.id);
    }

    let token: string;
    try {
      token = await getAuth(ensureAdminApp()).createCustomToken(account.id, {
        login: account.login,
      });
    } catch (error) {
      const detail = error instanceof Error ? error.message : String(error);
      logger.error('accounts: createCustomToken failed', {
        accountId: account.id,
        detail,
      });
      throw new HttpsError(
        'failed-precondition',
        `account/custom-token-failed: ${detail.slice(0, 300)}`,
      );
    }
    logger.info('accounts: вход', { accountId: account.id });
    return { token, account: toPublic(account) };
  },
);


/** Список аккаунтов: администратор видит всех, остальные — только себя. */
export const accountList = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    ensureAdminApp();

    const uid = await requireAuthUid(request);
    const caller = await accountById(uid);
    if (!caller) throw new HttpsError('not-found', 'account/not-found');

    if (caller.role !== 'admin') return [toPublic(caller)];

    const snapshot = await accounts().limit(200).get();
    return snapshot.docs.map((doc) => toPublic(doc.data() as AccountDoc));
  },
);

/** Изменение имени, роли, пароля и прав видимости. */
export const accountUpdate = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    ensureAdminApp();

    const uid = await requireAuthUid(request);
    const input = (request.data ?? {}) as Record<string, unknown>;
    const id = readString(input.id, uid) || uid;

    const caller = await accountById(uid);
    const target = await accountById(id);
    if (!caller || !target) {
      throw new HttpsError('not-found', 'account/not-found');
    }

    const isSelf = caller.id === target.id;
    const isAdmin = caller.role === 'admin';
    if (!isSelf && !isAdmin) {
      throw new HttpsError('permission-denied', 'account/forbidden');
    }

    const patch: Record<string, unknown> = {};

    if (input.name !== undefined) {
      const name = readString(input.name).trim();
      if (!name || name.length > MAX_NAME_LENGTH) {
        throw new HttpsError('invalid-argument', 'account/bad-name');
      }
      patch.name = name;
    }

    if (input.role !== undefined) {
      if (!isAdmin) {
        throw new HttpsError('permission-denied', 'account/forbidden');
      }
      if (isSelf) {
        throw new HttpsError(
          'permission-denied',
          'account/cannot-change-own-role',
        );
      }
      const role = readRole(input.role);
      if (!role) throw new HttpsError('invalid-argument', 'account/bad-role');
      patch.role = role;
    }

    if (input.password !== undefined) {
      if (!isSelf && !isAdmin) {
        throw new HttpsError('permission-denied', 'account/forbidden');
      }
      const password = readString(input.password);
      if (password.length < MIN_PASSWORD_LENGTH) {
        throw new HttpsError('invalid-argument', 'account/weak-password');
      }
      const salt = newSalt();
      patch.passwordSalt = salt;
      patch.passwordHash = hashPassword(password, salt);
      patch.passwordAlgo = 'scrypt';
    }

    if (input.allMembersVisible !== undefined) {
      if (!isAdmin) {
        throw new HttpsError('permission-denied', 'account/forbidden');
      }
      patch.allMembersVisible = input.allMembersVisible === true;
    }

    if (input.visibleMemberIds !== undefined) {
      if (!isAdmin) {
        throw new HttpsError('permission-denied', 'account/forbidden');
      }
      const ids = readVisibleMembers(input.visibleMemberIds);
      if (!ids) throw new HttpsError('invalid-argument', 'account/bad-access');
      patch.visibleMemberIds = ids;
    }

    if (Object.keys(patch).length === 0) {
      throw new HttpsError('invalid-argument', 'account/empty-patch');
    }

    await accounts().doc(target.id).update(patch);
    return toPublic({ ...target, ...patch } as AccountDoc);
  },
);

/** Удаление аккаунта администратором (свой удалить нельзя). */
export const accountDelete = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    ensureAdminApp();

    const uid = await requireAuthUid(request);
    const input = (request.data ?? {}) as Record<string, unknown>;
    const id = readString(input.id);

    const caller = await accountById(uid);
    const target = await accountById(id);
    if (!caller || !target) {
      throw new HttpsError('not-found', 'account/not-found');
    }
    if (caller.role !== 'admin') {
      throw new HttpsError('permission-denied', 'account/forbidden');
    }
    if (target.id === caller.id) {
      throw new HttpsError(
        'permission-denied',
        'account/cannot-delete-self',
      );
    }

    const owned = await db()
      .collection('families')
      .where('ownerAuthUid', '==', target.id)
      .limit(1)
      .get();
    if (!owned.empty) {
      throw new HttpsError('failed-precondition', 'account/owns-family');
    }

    const families = await db()
      .collection('families')
      .where('memberUids', 'array-contains', target.id)
      .get();
    for (const family of families.docs) {
      const data = family.data();
      const memberUids: string[] = Array.isArray(data.memberUids)
        ? data.memberUids.filter(
            (value: unknown): value is string => typeof value === 'string',
          )
        : [];
      const batch = db().batch();
      batch.delete(family.ref.collection('members').doc(target.id));
      batch.update(family.ref, {
        memberUids: memberUids.filter((value) => value !== target.id),
      });
      await batch.commit();
    }

    const batch = db().batch();
    batch.delete(accounts().doc(target.id));
    batch.delete(logins().doc(target.loginLower));
    batch.delete(db().collection('users').doc(target.id));
    await batch.commit();

    try {
      await getAuth(ensureAdminApp()).deleteUser(target.id);
    } catch (error) {
      logger.warn('accounts: пользователь Firebase не удалён', {
        accountId: target.id,
        error,
      });
    }

    logger.info('accounts: удалён', { accountId: target.id });
    return { ok: true };
  },
);

