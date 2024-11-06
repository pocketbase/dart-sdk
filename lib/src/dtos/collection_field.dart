import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "../caster.dart" as caster;
import "jsonable.dart";

/// Response DTO of a single collection schema field.
@JsonSerializable(explicitToJson: true)
class CollectionField implements Jsonable {
  String get id => get<String>("id", "");
  set id(String val) => data["id"] = val;

  String get name => get<String>("name", "");
  set name(String val) => data["name"] = val;

  String get type => get<String>("type", "");
  set type(String val) => data["type"] = val;

  bool get system => get<bool>("system", false);
  set system(bool val) => data["system"] = val;

  bool get required => get<bool>("required", false);
  set required(bool val) => data["required"] = val;

  bool get presentable => get<bool>("presentable", false);
  set presentable(bool val) => data["presentable"] = val;

  bool get hidden => get<bool>("hidden", false);
  set hidden(bool val) => data["hidden"] = val;

  Map<String, dynamic> data = {};

  CollectionField([Map<String, dynamic>? data]) : data = data ?? {};

  static CollectionField fromJson(Map<String, dynamic> json) =>
      CollectionField(json);

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
  /// final field = CollectionField(data);
  /// final result0 = field.get<int>("a.b.c", 999); // 999
  /// final result1 = field.get<int>("a.b.2.b3"); // 3
  /// final result2 = field.get<String>("a.b.2.b3"); // "3"
  /// ```
  T get<T>(String fieldNameOrPath, [T? defaultValue]) {
    return caster.extract<T>(data, fieldNameOrPath, defaultValue);
  }
}
