import { logger } from 'firebase-functions';
import { onRequest } from 'firebase-functions/v2/https';

/** Регион всех функций — совпадает с регионом Firestore/Storage. */
export const FUNCTIONS_REGION = 'europe-west3';

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
