import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "schema_field.dart";

part "collection_model.g.dart";

/// Response DTO of a single collection model.
@JsonSerializable(explicitToJson: true)
class CollectionModel implements Jsonable {
  String id;
  String created;
  String updated;
  String name;
  List<SchemaField> schema;
  bool system;
  String? listRule;
  String? viewRule;
  String? createRule;
  String? updateRule;
  String? deleteRule;

  CollectionModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.name = "",
    this.schema = const [],
    this.system = false,
    this.listRule,
    this.viewRule,
    this.createRule,
    this.updateRule,
    this.deleteRule,
  });

  static CollectionModel fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CollectionModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
