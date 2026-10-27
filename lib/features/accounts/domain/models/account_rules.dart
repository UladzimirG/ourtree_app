// Правила, общие для клиента и сервера (см. `src/lib/accounts.ts`).

/// Логин: 2–32 символа, буквы, цифры, точка, дефис и подчёркивание.
final RegExp accountLoginPattern = RegExp(
  r'^[a-z0-9._-]{2,32}$',
  caseSensitive: false,
);

/// Минимальная длина пароля, которую принимает сервер.
const int accountMinPasswordLength = 4;

/// Срок жизни гостевой ссылки по умолчанию.
const int guestLinkDefaultTtlDays = 30;
