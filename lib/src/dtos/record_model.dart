import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "../caster.dart" as caster;
import "jsonable.dart";

part "record_model.g.dart";

/// Response DTO of a single record model.
@JsonSerializable(explicitToJson: true)
class RecordModel implements Jsonable {
  String id;
  String created;
  String updated;
  String collectionId;
  String collectionName;

  @JsonKey(includeToJson: false, includeFromJson: false) // manually serialized
  Map<String, List<RecordModel>> expand;

  @JsonKey(includeToJson: false, includeFromJson: false) // manually serialized
  Map<String, dynamic> data = {};

  final List<String> _singleExpandKeys = [];
  final List<String> _multiExpandKeys = [];

  RecordModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.collectionId = "",
    this.collectionName = "",
    Map<String, List<RecordModel>>? expand,
    Map<String, dynamic>? data,
  })  : expand = expand ?? {},
        data = data ?? {};

  static RecordModel fromJson(Map<String, dynamic> json) {
    final model = _$RecordModelFromJson(json)..expand = {};

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

    // attach the dynamic json fields to the model"s `data`
    // ---
    final baseFields = <String>[
      "id",
      "created",
      "updated",
      "collectionId",
      "collectionName",
      "expand",
    ];

    final rest = Map<String, dynamic>.from(json)
      ..removeWhere((key, value) => baseFields.contains(key));

    model.data = rest;

    return model;
  }

  /// Extracts a single value from [data] by a dot-notation path
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
  /// final record = RecordModel(data: data);
  /// final result0 = record.getDataValue<int>("a.b.c", "missing"); // "missing"
  /// final result1 = record.getDataValue<int>("a.b.2.b3"); // 3
  /// final result2 = record.getDataValue<String>("a.b.2.b3"); // "3"
  /// ```
  T getDataValue<T>(String fieldNameOrPath, [T? defaultValue]) {
    return caster.extract<T>(data, fieldNameOrPath, defaultValue);
  }

  /// An alias for [getDataValue<String>()].
  String getStringValue(String fieldNameOrPath, [String? defaultValue]) {
    return getDataValue<String>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [getDataValue<List<T>>()].
  List<T> getListValue<T>(String fieldNameOrPath, [List<T>? defaultValue]) {
    return getDataValue<List<T>>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [getDataValue<bool>()].
  bool getBoolValue(String fieldNameOrPath, [bool? defaultValue]) {
    return getDataValue<bool>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [getDataValue<int>()].
  int getIntValue(String fieldNameOrPath, [int? defaultValue]) {
    return getDataValue<int>(fieldNameOrPath, defaultValue);
  }

  /// An alias for [getDataValue<double>()].
  double getDoubleValue(String fieldNameOrPath, [double? defaultValue]) {
    return getDataValue<double>(fieldNameOrPath, defaultValue);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _$RecordModelToJson(this);

    // revert the expand format to the original
    json["expand"] = expand.map((k, v) {
      if (_singleExpandKeys.contains(k)) {
        return MapEntry(k, v.isEmpty ? null : v.first.toJson());
      }
      return MapEntry(k, v.map((e) => e.toJson()).toList());
    });

    // flatten the data map
    data.forEach((key, value) {
      json[key] = value;
    });

    return json;
  }

  @override
  String toString() => jsonEncode(toJson());
}
