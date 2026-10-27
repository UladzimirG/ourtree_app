import 'package:ourtree_app/core/utils/json_reader.dart';

/// Точка фокуса фотографии в процентах (0–100 по каждой оси).
///
/// Соответствует `{ x, y }` из `FamilyMedia.position` и
/// `FamilyMember.photoPosition`.
class PhotoPosition {
  const PhotoPosition({
    required this.x,
    required this.y,
  });

  /// Положение по горизонтали, проценты.
  final double x;

  /// Положение по вертикали, проценты.
  final double y;

  /// Значение по умолчанию — центр снимка.
  static const PhotoPosition center = PhotoPosition(x: 50, y: 50);

  factory PhotoPosition.fromJson(Map<String, dynamic> json) => PhotoPosition(
        x: readDouble(json['x']) ?? center.x,
        y: readDouble(json['y']) ?? center.y,
      );

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  PhotoPosition copyWith({
    double? x,
    double? y,
  }) =>
      PhotoPosition(
        x: x ?? this.x,
        y: y ?? this.y,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoPosition && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'PhotoPosition(x: $x, y: $y)';
}
