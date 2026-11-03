import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

void main() {
  test('MemberStory переживает JSON round-trip', () {
    const story = MemberStory(
      id: 'story-1',
      title: 'Как мы познакомились',
      text: 'Длинная история о первом дне.',
    );

    final restored = MemberStory.fromJson(story.toJson());

    expect(restored, story);
  });

  test('FamilyMember сохраняет истории и не пишет пустой список', () {
    const member = FamilyMember(
      id: 'm1',
      role: 'Мама',
      name: 'Оля',
      nickname: '',
      birthday: '1990-01-01',
      stories: [
        MemberStory(id: 's1', title: 'История', text: 'Текст'),
      ],
    );

    final json = member.toJson();
    final restored = FamilyMember.fromJson(json);

    expect(restored.stories, member.stories);

    const empty = FamilyMember(
      id: 'm2',
      role: 'Папа',
      name: 'Ваня',
      nickname: '',
      birthday: '1990-01-01',
    );
    expect(empty.toJson().containsKey('stories'), isFalse);
  });
}
