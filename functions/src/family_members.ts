import { logger } from 'firebase-functions';
import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

import { FUNCTIONS_REGION } from './region';

/** Firestore через Admin SDK (default app создаётся при необходимости). */
function adminDb() {
  const app = getApps()[0] ?? initializeApp();
  return getFirestore(app);
}

function uniqueStrings(raw: unknown, extra: string): string[] {
  const current: string[] = Array.isArray(raw)
    ? raw.filter((value): value is string => typeof value === 'string')
    : [];
  return Array.from(new Set([...current, extra]));
}

function sameList(left: unknown, right: string[]): boolean {
  if (!Array.isArray(left) || left.length !== right.length) return false;
  return right.every((value, index) => left[index] === value);
}

/**
 * Дописывает участника в денормализованные списки семьи.
 *
 * Клиент создаёт документ `families/{fid}/members/{authUid}` при входе по
 * коду, но менять `memberUids`/`memberIds` документа семьи правилами ему
 * запрещено. Без этого списка вход на новом устройстве не находил семью и
 * приложение оставалось на демо-архиве.
 */
export const familyMemberJoined = onDocumentCreated(
  {
    region: FUNCTIONS_REGION,
    document: 'families/{familyId}/members/{memberUid}',
  },
  async (event) => {
    const familyId = event.params.familyId;
    const memberUid = event.params.memberUid;
    const data = event.data?.data();
    if (!data) return;

    const userId =
      typeof data.userId === 'string' && data.userId.length > 0
        ? data.userId
        : memberUid;

    const familyRef = adminDb().collection('families').doc(familyId);
    const snapshot = await familyRef.get();
    if (!snapshot.exists) return;

    const family = snapshot.data() ?? {};
    const memberUids = uniqueStrings(family.memberUids, memberUid);
    const memberIds = uniqueStrings(family.memberIds, userId);

    if (
      sameList(family.memberUids, memberUids) &&
      sameList(family.memberIds, memberIds)
    ) {
      return;
    }

    await familyRef.update({ memberUids, memberIds });
    logger.info('family: участник добавлен в списки семьи', {
      familyId,
      memberUid,
      userId,
    });
  },
);
