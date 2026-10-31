// Экспорт текстов демо-архива в TSV-таблицу для правки во всех локализациях.
// Запуск: node tools/export_texts.js
// Результат: demo_texts.tsv (открывается в Excel/Google Sheets, UTF-8 с BOM).

const fs = require('fs');

const LANGS = ['ru', 'be', 'uk', 'en'];
const OUTPUT = 'demo_texts.tsv';

const GLOBAL_FIELDS = ['familyName', 'familySubtitle'];
const MEMBER_FIELDS = ['role', 'name', 'nickname', 'birthday', 'about'];
const EVENT_FIELDS = ['date', 'title', 'text', 'place'];

const rows = new Map();

function put(kind, id, field, lang, value) {
  const key = `${kind}\t${id}\t${field}`;
  if (!rows.has(key)) rows.set(key, { kind, id, field, values: {} });
  if (value !== undefined && value !== null) rows.get(key).values[lang] = String(value);
}

const clean = (value) => String(value).replace(/[\t\r\n]+/g, ' ');

for (const lang of LANGS) {
  const data = JSON.parse(fs.readFileSync(`assets/data/family_${lang}.json`, 'utf8'));

  for (const field of GLOBAL_FIELDS) put('global', '-', field, lang, data[field]);

  for (const member of data.members ?? []) {
    for (const field of MEMBER_FIELDS) put('member', member.id, field, lang, member[field]);

    (member.habits ?? []).forEach((value, index) => {
      put('member', member.id, `habits[${index}]`, lang, value);
    });
    (member.quotes ?? []).forEach((value, index) => {
      put('member', member.id, `quotes[${index}]`, lang, value);
    });
    (member.wishlist ?? []).forEach((item, index) => {
      put('member', member.id, `wishlist[${index}].title`, lang, item.title);
      put('member', member.id, `wishlist[${index}].note`, lang, item.note);
      put('member', member.id, `wishlist[${index}].url`, lang, item.url);
    });
  }

  for (const event of data.timelineEvents ?? []) {
    for (const field of EVENT_FIELDS) put('event', event.id, field, lang, event[field]);
  }
}

const lines = [`kind\tid\tfield\t${LANGS.join('\t')}`];
for (const row of rows.values()) {
  const cells = LANGS.map((lang) => clean(row.values[lang] ?? ''));
  lines.push([row.kind, row.id, row.field, ...cells].join('\t'));
}

// BOM, чтобы Excel корректно открыл кириллицу.
fs.writeFileSync(OUTPUT, `\uFEFF${lines.join('\r\n')}\r\n`, 'utf8');
console.log(`Готово: ${OUTPUT} (${rows.size} строк, ${LANGS.length} языка)`);
