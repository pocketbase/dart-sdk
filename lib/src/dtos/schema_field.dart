import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "schema_field.g.dart";

/// Response DTO of a single collection schema field.
@JsonSerializable(explicitToJson: true)
class SchemaField implements Jsonable {
  String id;
  String name;
  String type;
  bool system;
  bool required;
  bool unique;
  Map<String, dynamic> options;

  SchemaField({
    this.id = "",
    this.name = "",
    this.type = "",
    this.system = false,
    this.required = false,
    this.unique = false,
    this.options = const {},
  });

  static SchemaField fromJson(Map<String, dynamic> json) =>
      _$SchemaFieldFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SchemaFieldToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
