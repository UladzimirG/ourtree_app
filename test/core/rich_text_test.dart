import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';

void main() {
  test('stripRichText removes inline HTML tags', () {
    expect(
      stripRichText(
        '<em>Главный по неважным решениям. '
        'Специалист по понятным только ему шуткам</em>',
      ),
      'Главный по неважным решениям. '
      'Специалист по понятным только ему шуткам',
    );
  });

  test('stripRichText keeps text around tags and decodes entities', () {
    expect(
      stripRichText('Случайная встреча<em> где-то</em>&nbsp;во&nbsp;Вселенной'),
      'Случайная встреча где-то во Вселенной',
    );
  });
}
