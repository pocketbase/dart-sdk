import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "schema_field.dart";

part "collection_model.g.dart";

/// Response DTO of a single collection model.
@JsonSerializable(explicitToJson: true)
class CollectionModel implements Jsonable {
  String id;
  String type;
  String created;
  String updated;
  String name;
  bool system;
  String? listRule;
  String? viewRule;
  String? createRule;
  String? updateRule;
  String? deleteRule;
  List<SchemaField> schema;
  List<String> indexes;
  Map<String, dynamic> options;

  CollectionModel({
    this.id = "",
    this.type = "base",
    this.created = "",
    this.updated = "",
    this.name = "",
    this.system = false,
    this.listRule,
    this.viewRule,
    this.createRule,
    this.updateRule,
    this.deleteRule,
    this.schema = const [],
    this.indexes = const [],
    this.options = const {},
  });

  static CollectionModel fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CollectionModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
