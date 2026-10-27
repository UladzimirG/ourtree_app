// Правила, общие для клиента и сервера (см. `src/lib/accounts.ts`).

/// Минимальная и максимальная длина логина.
const int accountMinLoginLength = 2;
const int accountMaxLoginLength = 32;

/// Логин: 2–32 латинских символа, цифры, точка, дефис и подчёркивание.
final RegExp accountLoginPattern = RegExp(
  '^[a-z0-9._-]{$accountMinLoginLength,$accountMaxLoginLength}\$',
  caseSensitive: false,
);

/// Минимальная длина пароля — 4 символа.
const int accountMinPasswordLength = 4;

/// Срок жизни гостевой ссылки по умолчанию.
const int guestLinkDefaultTtlDays = 30;
