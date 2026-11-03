import { logger } from 'firebase-functions';
import { onRequest } from 'firebase-functions/v2/https';

import { FUNCTIONS_REGION } from './region';

/** Регион всех функций — совпадает с регионом Firestore/Storage. */
export { FUNCTIONS_REGION } from './region';

// Ежедневная уборка «мусора» в облаке: брошенные файлы, пустые и мёртвые семьи,
// просроченные коды приглашений. Подробности — в `cleanup.ts`.
export { scheduledCleanup } from './cleanup';

// Серверные аккаунты семьи: логин/пароль проверяются в Cloud Functions,
// клиент получает Firebase custom token (см. `accounts.ts`).
export {
  accountDelete,
  accountList,
  accountLogin,
  accountRegister,
  accountUpdate,
} from './accounts';

// Денормализованные списки участников: клиенту менять их правилами запрещено,
// поэтому вход по коду дописывает участника на сервере.
export { familyMemberJoined } from './family_members';

// Пуши: «семья обновилась» и ежедневные напоминания о днях рождения и событиях.
export { notifyFamilyUpdated, scheduledReminders } from './notifications';


/**
 * Проверка живости деплоя: GET /health → { ok: true }.
 *
 * Нужна, чтобы убедиться, что пайплайн `firebase deploy --only functions`
 * настроен, до того как появятся вебхуки платежей.
 */
export const health = onRequest(
  { region: FUNCTIONS_REGION },
  (request, response) => {
    logger.info('health check', { method: request.method });
    response.status(200).json({
      ok: true,
      service: 'ourtree',
      region: FUNCTIONS_REGION,
      time: new Date().toISOString(),
    });
  },
);
