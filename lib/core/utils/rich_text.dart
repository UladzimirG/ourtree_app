/// Убирает простую HTML-разметку, которую хранят описания профилей и событий.
///
/// В старом проекте `about` и `text` могли содержать `<em>`/`<strong>`.
/// Flutter не умеет показывать HTML напрямую, поэтому теги аккуратно убираем.
String stripRichText(String value) => value
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&');
