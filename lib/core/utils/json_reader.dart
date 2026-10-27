/// Безопасное чтение значений из JSON, который приходит с сервера.
///
/// Данные лежат в файлах, которые могли править вручную, поэтому модели не
/// полагаются на точные типы и подставляют безопасные значения по умолчанию
/// вместо падения на `as`.
String readString(Object? value, {String fallback = ''}) =>
    value is String ? value : fallback;

String? readNullableString(Object? value) => value is String ? value : null;

int? readInt(Object? value) => value is num ? value.toInt() : null;

double? readDouble(Object? value) => value is num ? value.toDouble() : null;

bool? readBool(Object? value) => value is bool ? value : null;

List<String> readStringList(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const <String>[];

Map<String, dynamic>? readMap(Object? value) =>
    value is Map ? value.cast<String, dynamic>() : null;

List<Map<String, dynamic>> readMapList(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .toList(growable: false)
    : const <Map<String, dynamic>>[];
