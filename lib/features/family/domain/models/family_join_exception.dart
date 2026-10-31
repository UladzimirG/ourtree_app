/// Ошибки присоединения к семье по коду.
///
/// Отдельный тип вместо строк: UI показывает локализованный текст, а тесты
/// проверяют именно причину отказа.
sealed class FamilyJoinException implements Exception {
  const FamilyJoinException();
}

/// Код не соответствует формату (8 символов алфавита без похожих букв).
class InvalidInviteCodeException extends FamilyJoinException {
  const InvalidInviteCodeException();
}

/// Код не найден, отозван или истёк.
class InviteNotFoundException extends FamilyJoinException {
  const InviteNotFoundException();
}
