// ignore_for_file: deprecated_member_use_from_same_package

import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "../caster.dart" as caster;
import "jsonable.dart";

//part "record_model.g.dart"; // not actually used

/// Response DTO of a single record model.
@JsonSerializable()
class RecordModel implements Jsonable {
  String get id => get<String>("id", "");
  set id(String val) => data["id"] = val;

  String get collectionId => get<String>("collectionId");

  String get collectionName => get<String>("collectionName");

  @Deprecated(
    "created is no longer mandatory field; use get<String>('created')",
  )
  String get created => get<String>("created");

  @Deprecated(
    "updated is no longer mandatory field; use get<String>('updated')",
  )
  String get updated => get<String>("updated");

  Map<String, dynamic> data;

  @Deprecated("""
This field is superseded by the more generic get<T>(keyPath) method.
You can access the expanded record models and fields using dot-notation similar to the regular record fields:
record.get<String>("expand.user.email");
record.get<RecordModel>("expand.user");
record.get<List<RecordModel>>("expand.products");
  """)
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, List<RecordModel>> expand = {};

  final List<String> _singleExpandKeys = [];
  final List<String> _multiExpandKeys = [];

  RecordModel([Map<String, dynamic>? data]) : data = data ?? {};

  static RecordModel fromJson(Map<String, dynamic> json) {
    final model = RecordModel(json);

    // @todo remove with the expand field removal
    //
    // resolve and normalize the expand item(s) recursively
    (json["expand"] as Map<String, dynamic>? ?? {}).forEach((key, value) {
      final result = <RecordModel>[];

      if (value is Iterable) {
        model._multiExpandKeys.add(key);
        for (final item in value) {
          result.add(RecordModel.fromJson(item as Map<String, dynamic>? ?? {}));
        }
      }

      if (value is Map) {
        model._singleExpandKeys.add(key);
        result.add(RecordModel.fromJson(value as Map<String, dynamic>? ?? {}));
      }

      model.expand[key] = result;
    });

    return model;
  }

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  @override
  String toString() => jsonEncode(data);

  /// Extracts a single model value by a dot-notation path
  /// and tries to cast it to the specified generic type.
  ///
  /// If explicitly set, returns [defaultValue] on missing path.
  ///
  /// For more details about the casting rules, please refer to
  /// [caster.extract()].
  ///
  /// Example:
  ///
  /// ```dart
  /// final data = {"a": {"b": [{"b1": 1}, {"b2": 2}, {"b3": 3}]}};
  /// final record = RecordModel(data);
  /// final result0 = record.get<int>("a.b.c", 999); // 999
  /// final result1 = record.get<int>("a.b.2.b3"); // 3
  /// final result2 = record.get<String>("a.b.2.b3"); // "3"
  /// ```
  T get<T>(String fieldNameOrPath, [T? defaultValue]) {
    return caster.extract<T>(data, fieldNameOrPath, defaultValue);
  }

  // Updates a single Record field value.
  void set(String fieldName, dynamic value) {
    data[fieldName] = value;
  }

  @Deprecated("use get<T>(...)")
  T getDataValue<T>(String fieldNameOrPath, [T? defaultValue]) {
    return caster.extract<T>(data, fieldNameOrPath, defaultValue);
  }

  /// An alias for [get<String>()].
  String getStringValue(String fieldNameOrPath, [String? defaultValue]) {
    return get<String>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [get<List<T>>()].
  List<T> getListValue<T>(String fieldNameOrPath, [List<T>? defaultValue]) {
    return get<List<T>>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [get<bool>()].
  bool getBoolValue(String fieldNameOrPath, [bool? defaultValue]) {
    return get<bool>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [get<int>()].
  int getIntValue(String fieldNameOrPath, [int? defaultValue]) {
    return get<int>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [get<double>()].
  double getDoubleValue(String fieldNameOrPath, [double? defaultValue]) {
    return get<double>(fieldNameOrPath, defaultValue);
  }
}
