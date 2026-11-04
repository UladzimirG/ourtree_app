import { logger } from 'firebase-functions';
import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { FUNCTIONS_REGION } from './region';

/** Куда ведёт клик по уведомлению. */
const APP_LINK = 'https://ourtree-dev.web.app/';

/** FCM принимает не больше 500 токенов за один вызов. */
const TOKENS_PER_CALL = 500;

function adminDb() {
  const app = getApps()[0] ?? initializeApp();
  return getFirestore(app);
}

type Prefs = {
  birthdays?: boolean;
  calendar?: boolean;
  familyUpdates?: boolean;
};

type Device = {
  id: string;
  token: string;
  locale: string;
  offsetMinutes: number;
  prefs: Prefs;
  role: string;
};

type PushText = { title: string; body: string; type: string };

const TEXTS: Record<
  string,
  {
    familyTitle: string;
    familyBody: (count: number) => string;
    today: string;
    tomorrow: string;
    birthday: (name: string) => string;
  }
> = {
  ru: {
    familyTitle: 'Семья обновилась',
    familyBody: (count) => `Изменений в архиве: ${count}`,
    today: 'Сегодня в семье',
    tomorrow: 'Завтра в семье',
    birthday: (name) => `День рождения: ${name}`,
  },
  en: {
    familyTitle: 'Family updated',
    familyBody: (count) => `${count} changes in the archive`,
    today: 'Today in the family',
    tomorrow: 'Tomorrow in the family',
    birthday: (name) => `Birthday: ${name}`,
  },
  be: {
    familyTitle: 'Сямʼя абнавілася',
    familyBody: (count) => `Змен у архіве: ${count}`,
    today: 'Сёння ў сямʼі',
    tomorrow: 'Заўтра ў сямʼі',
    birthday: (name) => `Дзень нараджэння: ${name}`,
  },
  uk: {
    familyTitle: 'Родина оновилася',
    familyBody: (count) => `Змін в архіві: ${count}`,
    today: 'Сьогодні в родині',
    tomorrow: 'Завтра в родині',
    birthday: (name) => `День народження: ${name}`,
  },
};

function textFor(locale: string) {
  return TEXTS[locale] ?? TEXTS.en;
}

function readPrefs(raw: unknown): Prefs {
  const value =
    raw && typeof raw === 'object' ? (raw as Record<string, unknown>) : {};
  return {
    birthdays: value.birthdays !== false,
    calendar: value.calendar !== false,
    familyUpdates: value.familyUpdates !== false,
  };
}

/** Устройства семьи, которым можно писать по заданному поводу. */
async function loadDevices(
  familyId: string,
  need: 'familyUpdates' | 'reminders',
): Promise<Device[]> {
  const snapshot = await adminDb()
    .collection('families')
    .doc(familyId)
    .collection('devices')
    .get();

  const devices: Device[] = [];
  for (const doc of snapshot.docs) {
    const data = doc.data() ?? {};
    const token = typeof data.token === 'string' ? data.token : '';
    if (!token) continue;

    const prefs = readPrefs(data.prefs);
    const role = typeof data.role === 'string' ? data.role : 'member';
    if (need === 'familyUpdates') {
      // «Кто-то изменил данные семьи» присылаем только администратору.
      if (!prefs.familyUpdates || role !== 'admin') continue;
    }
    if (need === 'reminders' && !prefs.birthdays && !prefs.calendar) continue;

    devices.push({
      id: doc.id,
      token,
      locale: typeof data.locale === 'string' ? data.locale : 'en',
      offsetMinutes:
        typeof data.timezoneOffsetMinutes === 'number'
          ? data.timezoneOffsetMinutes
          : 0,
      prefs,
      role,
    });
  }
  return devices;
}

/** Отправляет одно сообщение списку устройств и чистит мёртвые токены. */
async function sendMessage(
  familyId: string,
  devices: Device[],
  message: PushText,
): Promise<void> {
  for (let start = 0; start < devices.length; start += TOKENS_PER_CALL) {
    const chunk = devices.slice(start, start + TOKENS_PER_CALL);
    const response = await getMessaging().sendEachForMulticast({
      tokens: chunk.map((device) => device.token),
      notification: { title: message.title, body: message.body },
      data: { type: message.type, familyId },
      webpush: { fcmOptions: { link: APP_LINK } },
      android: { priority: 'high' },
    });

    await Promise.all(
      response.responses.map(async (result, index) => {
        if (result.success) return;
        const code = result.error?.code ?? '';
        if (
          code !== 'messaging/registration-token-not-registered' &&
          code !== 'messaging/invalid-argument'
        ) {
          logger.warn('push: не доставлено', { familyId, code });
          return;
        }
        const deviceId = chunk[index]?.id;
        if (!deviceId) return;
        try {
          await adminDb()
            .collection('families')
            .doc(familyId)
            .collection('devices')
            .doc(deviceId)
            .delete();
        } catch (error) {
          logger.warn('push: не удалось удалить мёртвый токен', {
            familyId,
            deviceId,
            error,
          });
        }
      }),
    );
  }
}


/** Карта отметок сущностей; ранние версии клиента писали её строкой. */
function stampMap(raw: unknown): Record<string, number> {
  let value: unknown = raw;
  if (typeof value === 'string') {
    try {
      value = JSON.parse(value);
    } catch {
      return {};
    }
  }
  if (!value || typeof value !== 'object' || Array.isArray(value)) return {};

  const result: Record<string, number> = {};
  for (const [key, item] of Object.entries(value as Record<string, unknown>)) {
    if (typeof item === 'number') result[key] = item;
  }
  return result;
}

/** Сколько сущностей изменилось между двумя версиями архива. */
function countChangedEntities(
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown>,
): number {
  const liveBefore = stampMap(before?.entityUpdatedAt);
  const liveAfter = stampMap(after.entityUpdatedAt);
  const goneBefore = stampMap(before?.entityDeletedAt);
  const goneAfter = stampMap(after.entityDeletedAt);

  const keys = new Set([
    ...Object.keys(liveBefore),
    ...Object.keys(liveAfter),
    ...Object.keys(goneBefore),
    ...Object.keys(goneAfter),
  ]);

  let count = 0;
  for (const key of keys) {
    if ((liveBefore[key] ?? 0) !== (liveAfter[key] ?? 0)) {
      count++;
      continue;
    }
    if ((goneBefore[key] ?? 0) !== (goneAfter[key] ?? 0)) count++;
  }
  return count;
}

/** Пуш «кто-то обновил семейный архив». */
export const notifyFamilyUpdated = onDocumentWritten(
  { region: FUNCTIONS_REGION, document: 'families/{familyId}/state/current' },
  async (event) => {
    const after = event.data?.after.data() as
      | Record<string, unknown>
      | undefined;
    if (!after) return; // документ удалили — молчим
    const before = event.data?.before.data() as
      | Record<string, unknown>
      | undefined;

    const changed = countChangedEntities(before, after);
    if (changed <= 0) return;

    const familyId = event.params.familyId;
    const writerId = typeof after.writerId === 'string' ? after.writerId : '';
    const devices = (await loadDevices(familyId, 'familyUpdates')).filter(
      (device) => device.id !== writerId,
    );
    if (!devices.length) {
      logger.info('push: нет устройства администратора для уведомления', {
        familyId,
        changed,
        writerId,
      });
      return;
    }
    logger.info('push: изменения семьи', {
      familyId,
      changed,
      devices: devices.length,
    });

    const byLocale = new Map<string, Device[]>();
    for (const device of devices) {
      const list = byLocale.get(device.locale) ?? [];
      list.push(device);
      byLocale.set(device.locale, list);
    }

    for (const [locale, group] of byLocale) {
      const text = textFor(locale);
      await sendMessage(familyId, group, {
        title: text.familyTitle,
        body: text.familyBody(changed),
        type: 'family_updated',
      });
    }
  },
);

type ReminderItem = { kind: 'birthday' | 'event'; title: string };

type DayStamp = { month: number; day: number; iso: string };

/** Календарный день в часовом поясе устройства (без серверной зоны). */
function dayFor(now: Date, offsetMinutes: number, plusDays: number): DayStamp {
  const shifted = new Date(
    now.getTime() + offsetMinutes * 60_000 + plusDays * 86_400_000,
  );
  const month = shifted.getUTCMonth() + 1;
  const day = shifted.getUTCDate();
  const pad = (value: number) => String(value).padStart(2, '0');
  return {
    month,
    day,
    iso: `${shifted.getUTCFullYear()}-${pad(month)}-${pad(day)}`,
  };
}

function parseDate(raw: unknown): { month: number; day: number; iso: string } | null {
  if (typeof raw !== 'string') return null;
  const trimmed = raw.trim();
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(trimmed);
  if (!match) return null;
  return {
    month: Number(match[2]),
    day: Number(match[3]),
    iso: trimmed,
  };
}

/** Что напомнить в конкретный день: дни рождения и события календаря. */
function remindersFor(
  state: Record<string, unknown>,
  day: DayStamp,
): ReminderItem[] {
  const items: ReminderItem[] = [];
  const events = Array.isArray(state.timelineEvents)
    ? (state.timelineEvents as unknown[])
    : [];
  const birthMembers = new Set<string>();

  for (const raw of events) {
    if (!raw || typeof raw !== 'object') continue;
    const event = raw as Record<string, unknown>;
    if (event.showInCalendar === false) continue;

    const date = parseDate(event.date);
    if (!date) continue;

    const matches =
      event.recurringYearly === true
        ? date.month === day.month && date.day === day.day
        : date.iso === day.iso;
    if (!matches) continue;

    const title = typeof event.title === 'string' ? event.title : '';
    if (!title) continue;
    items.push({ kind: 'event', title });

    if (event.kind === 'birth' && typeof event.memberId === 'string') {
      birthMembers.add(event.memberId);
    }
  }

  const members = Array.isArray(state.members)
    ? (state.members as unknown[])
    : [];
  for (const raw of members) {
    if (!raw || typeof raw !== 'object') continue;
    const member = raw as Record<string, unknown>;
    if (member.showInCalendar === false) continue;

    const birthday = parseDate(member.birthday);
    if (!birthday || birthday.month !== day.month || birthday.day !== day.day) {
      continue;
    }

    const id = typeof member.id === 'string' ? member.id : '';
    if (id && birthMembers.has(id)) continue;

    const name =
      typeof member.name === 'string' ? member.name.trim() : '';
    if (!name) continue;
    items.push({ kind: 'birthday', title: name });
  }

  return items;
}

/** Ежедневные напоминания о днях рождения и событиях календаря. */
export const scheduledReminders = onSchedule(
  {
    region: FUNCTIONS_REGION,
    schedule: 'every day 09:00',
    timeZone: 'Europe/Minsk',
  },
  async () => {
    const now = new Date();
    const families = await adminDb().collection('families').get();

    for (const family of families.docs) {
      const stateSnapshot = await family.ref
        .collection('state')
        .doc('current')
        .get();
      const state = stateSnapshot.data() as
        | Record<string, unknown>
        | undefined;
      if (!state) continue;

      const devices = await loadDevices(family.id, 'reminders');
      if (!devices.length) continue;

      // Группируем по часовому поясу, локали и включённым категориям.
      const groups = new Map<
        string,
        {
          devices: Device[];
          locale: string;
          offset: number;
          birthdays: boolean;
          calendar: boolean;
        }
      >();

      for (const device of devices) {
        const key = `${device.offsetMinutes}|${device.locale}|${
          device.prefs.birthdays ? 1 : 0
        }${device.prefs.calendar ? 1 : 0}`;
        const group = groups.get(key) ?? {
          devices: [],
          locale: device.locale,
          offset: device.offsetMinutes,
          birthdays: device.prefs.birthdays === true,
          calendar: device.prefs.calendar === true,
        };
        group.devices.push(device);
        groups.set(key, group);
      }

      for (const group of groups.values()) {
        for (const plusDays of [0, 1]) {
          const day = dayFor(now, group.offset, plusDays);
          const items = remindersFor(state, day).filter((item) =>
            item.kind === 'birthday' ? group.birthdays : group.calendar,
          );
          if (!items.length) continue;

          const text = textFor(group.locale);
          const lines = items.map((item) =>
            item.kind === 'birthday' ? text.birthday(item.title) : item.title,
          );

          await sendMessage(family.id, group.devices, {
            title: plusDays === 0 ? text.today : text.tomorrow,
            body: lines.join('\n'),
            type: 'reminder',
          });
        }
      }
    }
  },
);

