// Импорт правок из demo_texts.tsv обратно в assets/data/family_<lang>.json.
// Запуск: node tools/import_texts.js
// Формат не меняется: правки вносятся точечно, отступы и переводы строк сохраняются.

const fs = require('fs');

const LANGS = ['ru', 'be', 'uk', 'en'];
const SOURCE = 'demo_texts.tsv';

const DATE_FIELDS = new Set(['birthday', 'date']);

function findObject(text, id) {
  const idIndex = text.indexOf(`"id": "${id}"`);
  if (idIndex < 0) return null;
  const start = text.lastIndexOf('{', idIndex);
  let depth = 0;
  for (let i = start; i < text.length; i++) {
    if (text[i] === '{') depth++;
    if (text[i] === '}') {
      depth--;
      if (depth === 0) return { start, end: i };
    }
  }
  return null;
}

function replaceField(block, field, value) {
  const pattern = new RegExp(`("${field}"\\s*:\\s*)"(?:[^"\\\\]|\\\\.)*"`);
  if (!pattern.test(block)) return null;
  return block.replace(pattern, `$1${JSON.stringify(value)}`);
}

function findArray(block, key) {
  const keyIndex = block.indexOf(`"${key}"`);
  if (keyIndex < 0) return null;
  const start = block.indexOf('[', keyIndex);
  if (start < 0) return null;
  let depth = 0;
  for (let i = start; i < block.length; i++) {
    if (block[i] === '[') depth++;
    else if (block[i] === ']') {
      depth--;
      if (depth === 0) return { start, end: i };
    }
  }
  return null;
}

// Границы элементов массива верхнего уровня: объекты {} или строки "".
function itemSpans(block, arr, open, close) {
  const spans = [];

  // Строковые элементы: кавычка одновременно открывает и закрывает элемент.
  if (open === '"') {
    let i = arr.start + 1;
    while (i < arr.end) {
      if (block[i] === '"') {
        const start = i;
        i++;
        while (i < arr.end && block[i] !== '"') {
          if (block[i] === '\\') i++;
          i++;
        }
        spans.push({ start, end: i });
      }
      i++;
    }
    return spans;
  }

  let depth = 0;
  let start = -1;
  for (let i = arr.start + 1; i < arr.end; i++) {
    const ch = block[i];
    if (ch === open) {
      if (depth === 0) start = i;
      depth++;
    } else if (ch === close) {
      depth--;
      if (depth === 0) spans.push({ start, end: i });
    }
  }
  return spans;
}

function removeField(block, field) {
  const pattern = new RegExp(`\\s*"${field}"\\s*:\\s*"(?:[^"\\\\]|\\\\.)*",?`);
  if (!pattern.test(block)) return null;
  let out = block.replace(pattern, '');
  out = out.replace(/,\s*(\n\s*})/, '$1');
  return out;
}

function applyIndexed(block, field, value) {
  const listMatch = field.match(/^(habits|quotes)\[(\d+)\]$/);
  if (listMatch) {
    const arr = findArray(block, listMatch[1]);
    if (!arr) return null;
    const items = itemSpans(block, arr, '"', '"');
    const item = items[Number(listMatch[2])];
    if (!item) return null;
    return block.slice(0, item.start) + JSON.stringify(value) + block.slice(item.end + 1);
  }

  const wishMatch = field.match(/^wishlist\[(\d+)\]\.(title|note|url)$/);
  if (wishMatch) {
    const arr = findArray(block, 'wishlist');
    if (!arr) return null;
    const items = itemSpans(block, arr, '{', '}');
    const item = items[Number(wishMatch[1])];
    if (!item) return null;
    const element = block.slice(item.start, item.end + 1);
    const prop = wishMatch[2];

    if (value === '-' && prop !== 'title') {
      const removed = removeField(element, prop);
      if (removed === null) return null;
      return block.slice(0, item.start) + removed + block.slice(item.end + 1);
    }

    const replaced = replaceField(element, prop, value);
    if (replaced === null) return null;
    return block.slice(0, item.start) + replaced + block.slice(item.end + 1);
  }

  return null;
}

const rawBuffer = fs.readFileSync(SOURCE);
let raw;
if (rawBuffer.length > 1 && rawBuffer[0] === 0xff && rawBuffer[1] === 0xfe) {
  // Excel «Юникод-текст» сохраняет UTF-16LE с BOM.
  raw = rawBuffer.slice(2).toString('utf16le');
} else if (rawBuffer.length > 2 && rawBuffer[0] === 0xef && rawBuffer[1] === 0xbb && rawBuffer[2] === 0xbf) {
  raw = rawBuffer.slice(3).toString('utf8');
} else {
  raw = rawBuffer.toString('utf8');
}
const lines = raw.split(/\r?\n/).filter((line) => line.trim() !== '');
const header = lines.shift().split('\t');
const langIndex = {};
for (const lang of LANGS) langIndex[lang] = header.indexOf(lang);

const report = [];
const files = {};
for (const lang of LANGS) {
  const original = fs.readFileSync(`assets/data/family_${lang}.json`, 'utf8');
  files[lang] = {
    text: original.replace(/\r\n/g, '\n'),
    usesCrlf: original.includes('\r\n'),
  };
}

let updated = 0;
let skipped = 0;

for (const line of lines) {
  const cells = line.split('\t');
  const [kind, id, field] = cells;

  for (const lang of LANGS) {
    const index = langIndex[lang];
    if (index < 0) continue;
    const value = cells[index];
    if (value === undefined || value.trim() === '') continue;

    if (DATE_FIELDS.has(field) && !/^\d{4}-\d{2}-\d{2}$/.test(value.trim())) {
      report.push(`${lang}: ${kind}/${id}.${field} — неверная дата '${value}', пропущено`);
      skipped++;
      continue;
    }

    const state = files[lang];
    let changed = false;

    if (kind === 'global') {
      const replaced = replaceField(state.text, field, value);
      if (replaced && replaced !== state.text) {
        state.text = replaced;
        changed = true;
      }
    } else {
      const span = findObject(state.text, id);
      if (!span) {
        report.push(`${lang}: ${kind} '${id}' не найден`);
        continue;
      }
      const block = state.text.slice(span.start, span.end);
      const replaced = field.includes('[')
        ? applyIndexed(block, field, value)
        : replaceField(block, field, value);
      if (replaced === null) {
        skipped++;
        continue;
      }
      if (replaced !== block) {
        state.text = state.text.slice(0, span.start) + replaced + state.text.slice(span.end);
        changed = true;
      }
    }

    if (changed) updated++;
  }
}

for (const lang of LANGS) {
  const state = files[lang];
  const original = fs.readFileSync(`assets/data/family_${lang}.json`, 'utf8');
  let text = state.text;
  if (state.usesCrlf) text = text.replace(/\n/g, '\r\n');
  if (text !== original) {
    try {
      JSON.parse(text);
    } catch (error) {
      report.push(`${lang}: ОШИБКА — результат невалидный JSON (${error.message}); файл НЕ изменён`);
      continue;
    }
    fs.writeFileSync(`assets/data/family_${lang}.json`, text, 'utf8');
    report.push(`${lang}: файл обновлён`);
  }
}

report.push(`Изменено полей: ${updated}, пропущено: ${skipped}`);
fs.writeFileSync('.tmp_import_report.txt', report.join('\n'), 'utf8');
console.log(report.join('\n'));
