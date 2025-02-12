import "./dtos/record_model.dart";

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

  return cast<T>(rawValue);
}

Type identityType<T>() => T;

/// Attempts to cast the provided value into the specified type.
T cast<T>(dynamic rawValue) {
  switch (T) {
    case const (String):
      return toString(rawValue) as T;
    case const (bool):
      return toBool(rawValue) as T;
    case const (int):
      return toInt(rawValue) as T;
    case const (num):
    case const (double):
      return toDouble(rawValue) as T;
    case const (RecordModel):
      return toRecordModel(rawValue) as T;
    case const (List<dynamic>):
      return toList(rawValue) as T;
    case const (List<String>):
    case const (List<String?>):
      return toList<String>(rawValue) as T;
    case const (List<bool>):
    case const (List<bool?>):
      return toList<bool>(rawValue) as T;
    case const (List<int>):
    case const (List<int?>):
      return toList<int>(rawValue) as T;
    case const (List<double>):
    case const (List<double?>):
      return toList<double>(rawValue) as T;
    case const (List<num>):
    case const (List<num?>):
      return toList<num>(rawValue) as T;
    case const (List<RecordModel>):
    case const (List<RecordModel?>):
      return toList<RecordModel>(rawValue) as T;
    default:
      if (rawValue is T) {
        return rawValue;
      }

      // check against the nullable types
      if (null is T) {
        if (T == identityType<String?>()) {
          return toString(rawValue) as T;
        }
        if (T == identityType<bool?>()) {
          return toBool(rawValue) as T;
        }
        if (T == identityType<int?>()) {
          return toInt(rawValue) as T;
        }
        if (T == identityType<num?>() || T == identityType<double?>()) {
          return toDouble(rawValue) as T;
        }
        if (T == identityType<RecordModel?>()) {
          return toRecordModel(rawValue) as T;
        }
        if (T == identityType<List<dynamic>?>()) {
          return toList(rawValue) as T;
        }
        if (T == identityType<List<String>?>()) {
          return toList<String>(rawValue) as T;
        }
        if (T == identityType<List<bool>?>()) {
          return toList<bool>(rawValue) as T;
        }
        if (T == identityType<List<int>?>()) {
          return toList<int>(rawValue) as T;
        }
        if (T == identityType<List<double>?>()) {
          return toList<double>(rawValue) as T;
        }
        if (T == identityType<List<num>?>()) {
          return toList<num>(rawValue) as T;
        }
        if (T == identityType<List<RecordModel>?>()) {
          return toList<RecordModel>(rawValue) as T;
        }
      }

      throw StateError("Invalid or unknown type value");
  }
}

/// Returns [rawValue] as `String`.
///
/// For `null` values empty string is returned.
/// `toString()` is used for any other non-`String` value.
String toString(dynamic rawValue) {
  if (rawValue == null) {
    return "";
  }

  return rawValue is String ? rawValue : rawValue.toString();
}

/// Casts and returns [rawValue] as `List<T>`.
///
/// Non-List values will be casted to `T` and returned as wrapped `List<T>`
/// as long as the casted value is not `null`.
/// For example `toList<num>(true)` will be returned as `[1]`, but
/// `toList<num>(null)` will be returned as `[]`.
List<T> toList<T>(dynamic rawValue) {
  if (rawValue == null) {
    return <T>[];
  }

  if (rawValue is List) {
    return rawValue.map((item) => cast<T>(item)).toList();
  }

  final casted = cast<T>(rawValue);
  if (casted != null) {
    return <T>[casted];
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

RecordModel toRecordModel(dynamic rawValue) {
  if (rawValue is RecordModel) {
    return rawValue;
  }

  if (rawValue is Map<String, dynamic>) {
    return RecordModel.fromJson(rawValue);
  }

  return RecordModel();
}

List<RecordModel> toRecordModels(dynamic rawValue) {
  if (rawValue is List<RecordModel>) {
    return rawValue;
  }

  if (rawValue is RecordModel) {
    return [rawValue];
  }

  if (rawValue is List) {
    return rawValue.map(toRecordModel).toList();
  }

  if (rawValue is Map<String, dynamic>) {
    return [RecordModel.fromJson(rawValue)];
  }

  return [];
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
