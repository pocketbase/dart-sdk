import "package:http/http.dart" as http;

import "../client.dart";
import "../client_exception.dart";
import "../dtos/jsonable.dart";
import "../dtos/result_list.dart";
import "base_service.dart";

/// Base generic crud service that is intented to be used by all other
/// crud services.
abstract class BaseCrudService<M extends Jsonable> extends BaseService {
  BaseCrudService(PocketBase client) : super(client);

  /// The base url path that is used by the service.
  String get baseCrudPath;

  /// The factory function (eg. `fromJson()`) that will be used to
  /// decode the returned items from the crud endpoints.
  M itemFactoryFunc(Map<String, dynamic> json);

  /// Returns a list with all items batch fetched at once.
  Future<List<M>> getFullList({
    int batch = 200,
    String? expand,
    String? filter,
    String? sort,
    String? fields,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final result = <M>[];

    Future<List<M>> request(int page) async {
      return getList(
        page: page,
        perPage: batch,
        filter: filter,
        sort: sort,
        fields: fields,
        expand: expand,
        query: query,
        headers: headers,
      ).then((list) {
        result.addAll(list.items);

        if (list.items.isNotEmpty && list.totalItems > result.length) {
          return request(page + 1);
        }

        return result;
      });
    }

    return request(1);
  }

  /// Returns paginated items list.
  Future<ResultList<M>> getList({
    int page = 1,
    int perPage = 30,
    String? expand,
    String? filter,
    String? sort,
    String? fields,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["page"] = page;
    enrichedQuery["perPage"] = perPage;
    enrichedQuery["filter"] ??= filter;
    enrichedQuery["sort"] ??= sort;
    enrichedQuery["expand"] ??= expand;
    enrichedQuery["fields"] ??= fields;

    return client
        .send(
      baseCrudPath,
      query: enrichedQuery,
      headers: headers,
    )
        .then((data) {
      return ResultList<M>.fromJson(
        data as Map<String, dynamic>? ?? {},
        itemFactoryFunc,
      );
    });
  }

  /// Returns single item by its id.
  Future<M> getOne(
    String id, {
    String? expand,
    String? fields,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;
    enrichedQuery["fields"] ??= fields;

    return client
        .send(
          "$baseCrudPath/${Uri.encodeComponent(id)}",
          query: enrichedQuery,
          headers: headers,
        )
        .then((data) => itemFactoryFunc(data as Map<String, dynamic>? ?? {}));
  }

  /// Returns the first found list item by the specified filter.
  ///
  /// Internally it calls `getList()` and returns its first item.
  ///
  /// For consistency with `getOne`, this method will throw a 404
  /// `ClientException` if no item was found.
  Future<M> getFirstListItem(
    String filter, {
    String? expand,
    String? fields,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return getList(
      perPage: 1,
      filter: filter,
      expand: expand,
      fields: fields,
      query: query,
      headers: headers,
    ).then((result) {
      if (result.items.isEmpty) {
        throw ClientException(
          statusCode: 404,
          response: <String, dynamic>{
            "code": 404,
            "message": "The requested resource wasn't found.",
            "data": <String, dynamic>{},
          },
        );
      }

      return result.items.first;
    });
  }

  /// Creates a new item.
  Future<M> create({
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
    String? expand,
    String? fields,
  }) {
    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;
    enrichedQuery["fields"] ??= fields;

    return client
        .send(
          baseCrudPath,
          method: "POST",
          body: body,
          query: enrichedQuery,
          files: files,
          headers: headers,
        )
        .then((data) => itemFactoryFunc(data as Map<String, dynamic>? ?? {}));
  }

  /// Updates an single item by its id.
  Future<M> update(
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
    String? expand,
    String? fields,
  }) {
    final enrichedQuery = Map<String, dynamic>.of(query);
    enrichedQuery["expand"] ??= expand;
    enrichedQuery["fields"] ??= fields;

    return client
        .send(
          "$baseCrudPath/${Uri.encodeComponent(id)}",
          method: "PATCH",
          body: body,
          query: enrichedQuery,
          files: files,
          headers: headers,
        )
        .then((data) => itemFactoryFunc(data as Map<String, dynamic>? ?? {}));
  }

  /// Deletes an single item by its id.
  Future<void> delete(
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "$baseCrudPath/${Uri.encodeComponent(id)}",
      method: "DELETE",
      body: body,
      query: query,
      headers: headers,
    );
  }
}
