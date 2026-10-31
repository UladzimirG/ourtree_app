import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getApps, initializeApp } from 'firebase-admin/app';
import {
  Firestore,
  getFirestore,
  QueryDocumentSnapshot,
} from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

/** Регион — совпадает с регионом Firestore/Storage. */
export const CLEANUP_REGION = 'europe-west3';

const DAY_MS = 24 * 60 * 60 * 1000;

/** Сколько ждём, прежде чем считать файл без семьи брошенным. */
const ORPHAN_FILE_GRACE_MS = DAY_MS;
/** Семья, у которой вообще нет документов участников. */
const EMPTY_FAMILY_GRACE_MS = DAY_MS;
/** Семья, где все участники вышли (документы есть, но не активны). */
const INACTIVE_FAMILY_GRACE_MS = 30 * DAY_MS;
/** Просроченные коды приглашений живут ещё сутки — на случай возврата. */
const EXPIRED_INVITE_GRACE_MS = DAY_MS;

const PAGE_SIZE = 200;
const BATCH_SIZE = 400;

const FAMILIES = 'families';
const MEMBERS = 'members';
const INVITE_CODES = 'inviteCodes';
const STORAGE_PREFIX = 'families/';

type Bucket = ReturnType<ReturnType<typeof getStorage>['bucket']>;

export interface CleanupSummary {
  expiredInvites: number;
  orphanFiles: number;
  orphanFamilies: number;
  deadFamilies: number;
  errors: number;
  dryRun: boolean;
}

function ensureAdmin(): void {
  if (getApps().length === 0) initializeApp();
}

/**
 * Сборка мусора в облаке.
 *
 * Три прохода:
 *  1. Просроченные коды приглашений.
 *  2. Файлы Storage, у которых больше нет документа семьи (удаление с другого
 *     устройства не дошло, приложение снесли, данные стёрли из консоли).
 *  3. Семьи без активных участников: пустые (нет ни одного документа участника)
 *     или «мёртвые» (все вышли) и не обновлявшиеся дольше порога.
 *
 * Клиентское удаление (кнопка «Удалить данные семьи») делает то же самое сразу;
 * эта функция страхует случаи, когда клиент не смог довести уборку до конца.
 */
export async function runCleanup(
  options: { now?: number; dryRun?: boolean } = {},
): Promise<CleanupSummary> {
  ensureAdmin();

  const now = options.now ?? Date.now();
  const dryRun = options.dryRun ?? false;
  const db = getFirestore();
  const bucket = getStorage().bucket();

  const summary: CleanupSummary = {
    expiredInvites: 0,
    orphanFiles: 0,
    orphanFamilies: 0,
    deadFamilies: 0,
    errors: 0,
    dryRun,
  };

  summary.expiredInvites = await deleteExpiredInvites(db, now, dryRun);
  await deleteOrphanFiles(db, bucket, now, dryRun, summary);
  await deleteDeadFamilies(db, bucket, now, dryRun, summary);

  logger.info('cleanup: завершено', { ...summary });
  return summary;
}

async function deleteExpiredInvites(
  db: Firestore,
  now: number,
  dryRun: boolean,
): Promise<number> {
  const cutoff = now - EXPIRED_INVITE_GRACE_MS;
  let deleted = 0;

  for (;;) {
    const page = await db
      .collection(INVITE_CODES)
      .where('expiresAt', '<', cutoff)
      .limit(BATCH_SIZE)
      .get();
    if (page.empty) break;

    deleted += page.size;
    if (dryRun) break;

    const batch = db.batch();
    page.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    if (page.size < BATCH_SIZE) break;
  }

  return deleted;
}

async function deleteOrphanFiles(
  db: Firestore,
  bucket: Bucket,
  now: number,
  dryRun: boolean,
  summary: CleanupSummary,
): Promise<void> {
  const grouped = await collectFamilyFiles(bucket);

  for (const [familyId, info] of grouped) {
    const doc = await db.collection(FAMILIES).doc(familyId).get();
    if (doc.exists) continue;

    // Свежие файлы не трогаем: семья могла ещё не успеть записать документ.
    if (info.oldest > 0 && now - info.oldest < ORPHAN_FILE_GRACE_MS) continue;

    if (dryRun) {
      summary.orphanFiles += info.files;
      summary.orphanFamilies += 1;
      continue;
    }

    try {
      await bucket.deleteFiles({
        prefix: `${STORAGE_PREFIX}${familyId}/`,
        force: true,
      });
      summary.orphanFiles += info.files;
      summary.orphanFamilies += 1;
      logger.info('cleanup: удалены файлы семьи без документа', {
        familyId,
        files: info.files,
      });
    } catch (error) {
      summary.errors += 1;
      logger.error('cleanup: не удалось удалить файлы семьи', {
        familyId,
        error,
      });
    }
  }
}

async function collectFamilyFiles(
  bucket: Bucket,
): Promise<Map<string, { files: number; oldest: number }>> {
  const grouped = new Map<string, { files: number; oldest: number }>();
  const [files] = await bucket.getFiles({ prefix: STORAGE_PREFIX });

  for (const file of files) {
    const segments = file.name.split('/');
    // Ожидаем families/{familyId}/... — всё остальное не наше дело.
    if (segments.length < 3) continue;

    const familyId = segments[1];
    const createdAt = Date.parse(String(file.metadata?.timeCreated ?? '')) || 0;
    const entry = grouped.get(familyId);

    if (entry == null) {
      grouped.set(familyId, { files: 1, oldest: createdAt });
      continue;
    }

    entry.files += 1;
    if (createdAt > 0 && (entry.oldest === 0 || createdAt < entry.oldest)) {
      entry.oldest = createdAt;
    }
  }

  return grouped;
}

async function deleteDeadFamilies(
  db: Firestore,
  bucket: Bucket,
  now: number,
  dryRun: boolean,
  summary: CleanupSummary,
): Promise<void> {
  let cursor: QueryDocumentSnapshot | undefined;

  for (;;) {
    let query = db.collection(FAMILIES).orderBy('__name__').limit(PAGE_SIZE);
    if (cursor != null) query = query.startAfter(cursor);

    const page = await query.get();
    if (page.empty) break;

    for (const doc of page.docs) {
      const shouldPurge = await isDeadFamily(db, doc, now);
      if (!shouldPurge) continue;

      if (dryRun) {
        summary.deadFamilies += 1;
        continue;
      }

      try {
        await purgeFamily(db, bucket, doc.id);
        summary.deadFamilies += 1;
        logger.info('cleanup: удалена неиспользуемая семья', { familyId: doc.id });
      } catch (error) {
        summary.errors += 1;
        logger.error('cleanup: не удалось удалить семью', {
          familyId: doc.id,
          error,
        });
      }
    }

    if (page.size < PAGE_SIZE) break;
    cursor = page.docs[page.docs.length - 1];
  }
}

async function isDeadFamily(
  db: Firestore,
  doc: QueryDocumentSnapshot,
  now: number,
): Promise<boolean> {
  const data = doc.data() as { updatedAt?: number; createdAt?: number };
  const updatedAt = Number(data.updatedAt ?? data.createdAt ?? 0);
  if (updatedAt <= 0) return false;

  const members = doc.ref.collection(MEMBERS);

  const active = await members.where('status', '==', 'active').limit(1).get();
  if (!active.empty) return false;

  const anyMember = await members.limit(1).get();
  const grace = anyMember.empty
    ? EMPTY_FAMILY_GRACE_MS
    : INACTIVE_FAMILY_GRACE_MS;

  return now - updatedAt > grace;
}

async function purgeFamily(
  db: Firestore,
  bucket: Bucket,
  familyId: string,
): Promise<void> {
  try {
    await bucket.deleteFiles({
      prefix: `${STORAGE_PREFIX}${familyId}/`,
      force: true,
    });
  } catch (error) {
    // Файлов может уже не быть — это не повод оставлять документы семьи.
    logger.warn('cleanup: файлы семьи недоступны или уже удалены', {
      familyId,
      error,
    });
  }

  const invites = await db
    .collection(INVITE_CODES)
    .where('familyId', '==', familyId)
    .limit(BATCH_SIZE)
    .get();
  if (!invites.empty) {
    const batch = db.batch();
    invites.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }

  // recursiveDelete стирает документ вместе со всеми подколлекциями.
  await db.recursiveDelete(db.collection(FAMILIES).doc(familyId));
}

/** Ежедневная уборка: 03:00 по Берлину. */
export const scheduledCleanup = onSchedule(
  {
    schedule: 'every day 03:00',
    timeZone: 'Europe/Berlin',
    region: CLEANUP_REGION,
    timeoutSeconds: 540,
    memory: '512MiB',
  },
  async () => {
    await runCleanup();
  },
);
