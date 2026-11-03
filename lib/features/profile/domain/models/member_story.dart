import 'package:ourtree_app/core/utils/json_reader.dart';

/// Длинная история из блока «Интересное» в профиле участника.
///
/// Истории хранятся в самом профиле (`FamilyMember.stories`) и синхронизируются
/// вместе с ним: отдельная сущность синхронизации для них не нужна.
class MemberStory {
  const MemberStory({
    required this.id,
    required this.title,
    required this.text,
  });

  final String id;
  final String title;
  final String text;

  factory MemberStory.fromJson(Map<String, dynamic> json) => MemberStory(
        id: readString(json['id']),
        title: readString(json['title']),
        text: readString(json['text']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
      };

  MemberStory copyWith({
    String? id,
    String? title,
    String? text,
  }) =>
      MemberStory(
        id: id ?? this.id,
        title: title ?? this.title,
        text: text ?? this.text,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberStory &&
          id == other.id &&
          title == other.title &&
          text == other.text;

  @override
  int get hashCode => Object.hash(id, title, text);
}
