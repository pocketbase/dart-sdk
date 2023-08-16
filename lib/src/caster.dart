/// Extracts a single value from [data] by a dot-notation path
/// and tries to cast it to the specified generic type.
///
/// If explicitly set, returns [defaultValue] on missing path.
///
/// Example:
///
/// ```dart
/// final data = {"a": {"b": [{"b1": 1}, {"b2": 2}, {"b3": 3}]}};
/// final result1 = extract(data, "a.b.2.b3"); // 3
/// final result2 = extract(data, "a.b.c", "missing"); // "missing"
/// ```
T extract<T>(
  Map<String, dynamic> data,
  String path, [
  dynamic defaultValue,
]) {
  final rawValue = _extractNestedValue(data, path, defaultValue);

  switch (T) {
    case String:
      return toString(rawValue) as T;
    case bool:
      return toBool(rawValue) as T;
    case int:
      return toInt(rawValue) as T;
    case num:
    case double:
      return toDouble(rawValue) as T;
    case const(List<dynamic>):
      return toList(rawValue) as T;
    case const(List<String>):
      return toList<String>(rawValue) as T;
    case const(List<bool>):
      return toList<bool>(rawValue) as T;
    case const(List<int>):
      return toList<int>(rawValue) as T;
    case const(List<double>):
      return toList<double>(rawValue) as T;
    case const(List<num>):
      return toList<num>(rawValue) as T;
    default:
      if (rawValue is T) {
        return rawValue;
      }

      throw StateError("Invalid or unknown type value");
  }
}

/// Returns [rawValue] as **String**.
///
/// For `null` values empty string is returned.
/// `toString()` is used for any other non-String value.
String toString(dynamic rawValue) {
  if (rawValue == null) {
    return "";
  }

  return rawValue is String ? rawValue : rawValue.toString();
}

/// Returns [rawValue] as **List<T>**.
///
/// Non-List values that matches the generic type will be wrapped
/// (eg. `toList<num>(1)` will be returned as `[1]`).
///
/// Returns an empty list if [rawValue] is a no list of type `T` or
/// a single value of type `T`.
List<T> toList<T>(dynamic rawValue) {
  if (rawValue is List) {
    return rawValue.cast<T>();
  }

  if (rawValue is T) {
    return <T>[rawValue];
  }

  return <T>[];
}

/// Returns [rawValue] as **bool**.
///
/// For non-bool values the following casting rules are applied:
/// - `null` - always returned as `false`
/// - `num` - `false` if `0`, otherwise `true`
/// - `String` - `false` if one of `"", "false", "0"`, otherwise - `true`
/// - `List` and `Map` - `true` if `length > 0`, otherwise - `false`
/// - `false` for any other type
bool toBool(dynamic rawValue) {
  if (rawValue == null) {
    return false;
  }

  if (rawValue is bool) {
    return rawValue;
  }

  if (rawValue is num) {
    return rawValue != 0;
  }

  if (rawValue is String) {
    final falsyValues = <String>["", "false", "0"];

    return !falsyValues.contains(rawValue.toLowerCase());
  }

  if (rawValue is Iterable) {
    return rawValue.isNotEmpty;
  }

  if (rawValue is Map) {
    return rawValue.isNotEmpty;
  }

  return false;
}

/// Returns [rawValue] as **int**.
///
/// For non-num values the following casting rules are applied:
/// - `null` - always returned as `0`
/// - `String` - the non-null result of `int.tryParse()`, otherwise -`0`.
/// - `bool` - `false` -> `0`, `true` -> `1`
/// - `List` and `Map` - returns the length of the List/Map.
/// - `0` for any other type
int toInt(dynamic rawValue) {
  if (rawValue == null) {
    return 0;
  }

  if (rawValue is int) {
    return rawValue;
  }

  if (rawValue is double) {
    return rawValue.toInt();
  }

  if (rawValue is String) {
    return int.tryParse(rawValue) ?? 0;
  }

  if (rawValue is bool) {
    return rawValue ? 1 : 0;
  }

  if (rawValue is Iterable) {
    return rawValue.length;
  }

  if (rawValue is Map) {
    return rawValue.length;
  }

  return 0;
}

/// Returns [rawValue] as **double**.
///
/// For non-num values the following casting rules are applied:
/// - `null` - always returned as `0`
/// - `String` - the non-null result of `double.tryParse()`, otherwise -`0`.
/// - `bool` - `false` -> `0`, `true` -> `1`
/// - `List` and `Map` - returns the length of the List/Map.
/// - `0` for any other type
double toDouble(dynamic rawValue) {
  if (rawValue == null) {
    return 0;
  }

  if (rawValue is double) {
    return rawValue;
  }

  if (rawValue is int) {
    return rawValue.toDouble();
  }

  if (rawValue is String) {
    return double.tryParse(rawValue) ?? 0;
  }

  if (rawValue is bool) {
    return rawValue ? 1 : 0;
  }

  if (rawValue is Iterable) {
    return rawValue.length.toDouble();
  }

  if (rawValue is Map) {
    return rawValue.length.toDouble();
  }

  return 0;
}

dynamic _extractNestedValue(
  Map<String, dynamic> data,
  String path, [
  dynamic defaultValue,
]) {
  final parts = path.split(".");

  dynamic result = data;

  for (final part in parts) {
    if (result is Iterable) {
      result = _iterableToMap(result);
    }

    if (result is! Map || !result.containsKey(part)) {
      return defaultValue;
    }

    result = result[part];
  }

  return result;
}

Map<String, dynamic> _iterableToMap(Iterable<dynamic> data) {
  final result = <String, dynamic>{};

  for (var i = 0; i < data.length; i++) {
    result[i.toString()] = data.elementAt(i);
  }

  return result;
}
