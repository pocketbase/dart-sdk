import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "result_list.g.dart";

/// The factory function (eg. `fromJson()`) that will be used for a
/// single item in a paginated list.
typedef ListItemFactory<M extends Jsonable> = M Function(
  Map<String, dynamic> item,
);

/// Response DTO of a generic paginated list.
@JsonSerializable(explicitToJson: true)
class ResultList<M extends Jsonable> implements Jsonable {
  int page;
  int perPage;
  int totalItems;
  int totalPages;

  @JsonKey(includeToJson: false, includeFromJson: false) // manually serialized
  List<M> items;

  ResultList({
    this.page = 0,
    this.perPage = 0,
    this.totalItems = 0,
    this.totalPages = 0,
    this.items = const [],
  });

  factory ResultList.fromJson(
    Map<String, dynamic> json,
    ListItemFactory itemFactoryFunc,
  ) {
    final result = _$ResultListFromJson<M>(json)
      ..items = (json["items"] as List<dynamic>?)
              ?.map((item) => itemFactoryFunc(item as Map<String, dynamic>))
              .toList()
              .cast<M>() ??
          const [];

    return result;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _$ResultListToJson<M>(this);

    json["items"] = items.map((item) => item.toJson()).toList();

    return json;
  }

  @override
  String toString() => jsonEncode(toJson());
}
