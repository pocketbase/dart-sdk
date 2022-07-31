import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "record_model.g.dart";

/// Response DTO of a single record model.
@JsonSerializable(explicitToJson: true)
class RecordModel implements Jsonable {
  String id;
  String created;
  String updated;

  @JsonKey(name: "@collectionId")
  String collectionId;

  @JsonKey(name: "@collectionName")
  String collectionName;

  @JsonKey(name: "@expand")
  Map<String, dynamic> expand;

  @JsonKey(ignore: true) // manually serialized
  Map<String, dynamic> data;

  RecordModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.collectionId = "",
    this.collectionName = "",
    this.expand = const {},
    this.data = const {},
  });

  static RecordModel fromJson(Map<String, dynamic> json) {
    final model = _$RecordModelFromJson(json);

    // attach the dynamic json fields to the model"s `data`
    // ---
    final baseFields = <String>[
      "id",
      "created",
      "updated",
      "@collectionId",
      "@collectionName",
      "@expand",
    ];

    final rest = Map<String, dynamic>.from(json)
      ..removeWhere((key, value) => baseFields.contains(key));

    model.data = rest;

    return model;
  }

  /// Returns a single [data] value with key [fieldName] as **String**.
  ///
  /// For `null` values empty string is returned.
  /// `toString()` is used for any other non-String value.
  String getStringValue(String fieldName) {
    final rawValue = data[fieldName];

    if (rawValue == null) {
      return "";
    }

    return rawValue is String ? rawValue : rawValue.toString();
  }

  /// Returns a single [data] value with key [fieldName] as List.
  ///
  /// Non-List fields will be wrapped (eg. `1` will be returned as `[1]`).
  List<T> getListValue<T>(String fieldName) {
    final rawValue = data[fieldName];

    if (rawValue is List) {
      return rawValue.cast<T>();
    }

    if (rawValue is T) {
      return <T>[rawValue];
    }

    return <T>[];
  }

  /// Returns a single [data] value with key [fieldName] as **bool**.
  ///
  /// For non-num values the following casting rules are applied:
  /// - `null` - always returned as `false`
  /// - `num` - `false` if `0`, otherwise `true`
  /// - `String` - `false` if one of `"", "false", "0"`, otherwise - `true`
  /// - `List` and `Map` - `true` if `length > 0`, otherwise - `false`
  /// - `false` for any other type
  bool getBoolValue(String fieldName) {
    final rawValue = data[fieldName];

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

  /// Returns a single [data] value with key [fieldName] as **int**.
  ///
  /// For non-num values the following casting rules are applied:
  /// - `null` - always returned as `0`
  /// - `String` - the non-null result of `int.tryParse()`, otherwise -`0`.
  /// - `bool` - `false` -> `0`, `true` -> `1`
  /// - `List` and `Map` - returns the length of the List/Map.
  /// - `0` for any other type
  int getIntValue(String fieldName) {
    final rawValue = data[fieldName];

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

  /// Returns a single [data] value with key [fieldName] as **double**.
  ///
  /// For non-num values the following casting rules are applied:
  /// - `null` - always returned as `0`
  /// - `String` - the non-null result of `double.tryParse()`, otherwise -`0`.
  /// - `bool` - `false` -> `0`, `true` -> `1`
  /// - `List` and `Map` - returns the length of the List/Map.
  /// - `0` for any other type
  double getDoubleValue(String fieldName) {
    final rawValue = data[fieldName];

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

  @override
  Map<String, dynamic> toJson() {
    final json = _$RecordModelToJson(this);

    // flatten the data map
    data.forEach((key, value) {
      json[key] = value;
    });

    return json;
  }

  @override
  String toString() => jsonEncode(toJson());
}
