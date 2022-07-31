import "package:http/http.dart" as http;

import "../client.dart";
import "../dtos/jsonable.dart";
import "../dtos/result_list.dart";
import "base_service.dart";

/// Base generic crud service that is intented to be used by all other
/// crud services.
abstract class CrudService<M extends Jsonable> extends _BaseCrudService<M> {
  CrudService(PocketBase client) : super(client);

  /// The base url path that is used by the service.
  String get basePath;

  /// Returns a list with all items batch fetched at once.
  Future<List<M>> getFullList({
    int batch = 100,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _getFullList(
      basePath,
      batch: batch,
      filter: filter,
      sort: sort,
      query: query,
      headers: headers,
    );
  }

  /// Returns paginated items list.
  Future<ResultList<M>> getList({
    int page = 1,
    int perPage = 30,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _getList(
      basePath,
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      query: query,
      headers: headers,
    );
  }

  /// Returns single item by its id.
  Future<M> getOne(
    String id, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _getOne(
      "$basePath/${Uri.encodeComponent(id)}",
      query: query,
      headers: headers,
    );
  }

  /// Creates a new item.
  Future<M> create({
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
  }) {
    return _create(
      basePath,
      body: body,
      query: query,
      files: files,
      headers: headers,
    );
  }

  /// Updates an existing item by its id.
  Future<M> update(
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
  }) {
    return _update(
      "$basePath/${Uri.encodeComponent(id)}",
      body: body,
      query: query,
      files: files,
      headers: headers,
    );
  }

  /// Deletes an existing item by its id.
  Future<void> delete(
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _delete(
      "$basePath/${Uri.encodeComponent(id)}",
      body: body,
      query: query,
      headers: headers,
    );
  }
}

// -------------------------------------------------------------------

/// Base generic crud service that is intented to be used by all other
/// nested/sub crud services.
abstract class SubCrudService<M extends Jsonable> extends _BaseCrudService<M> {
  SubCrudService(PocketBase client) : super(client);

  /// The base url path that is used by the service.
  String basePath(String sub);

  /// Returns a list with all items batch fetched at once.
  Future<List<M>> getFullList(
    String sub, {
    int batch = 100,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _getFullList(
      basePath(sub),
      batch: batch,
      filter: filter,
      sort: sort,
      query: query,
      headers: headers,
    );
  }

  /// Returns paginated items list.
  Future<ResultList<M>> getList(
    String sub, {
    int page = 1,
    int perPage = 30,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _getList(
      basePath(sub),
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      query: query,
      headers: headers,
    );
  }

  /// Returns single item by its id.
  Future<M> getOne(
    String sub,
    String id, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _getOne(
      "${basePath(sub)}/${Uri.encodeComponent(id)}",
      query: query,
      headers: headers,
    );
  }

  /// Creates a new item.
  Future<M> create(
    String sub, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
  }) {
    return _create(
      basePath(sub),
      body: body,
      query: query,
      files: files,
      headers: headers,
    );
  }

  /// Updates an existing item by its id.
  Future<M> update(
    String sub,
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
  }) {
    return _update(
      "${basePath(sub)}/${Uri.encodeComponent(id)}",
      body: body,
      query: query,
      files: files,
      headers: headers,
    );
  }

  /// Deletes an existing item by its id.
  Future<void> delete(
    String sub,
    String id, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _delete(
      "${basePath(sub)}/${Uri.encodeComponent(id)}",
      body: body,
      query: query,
      headers: headers,
    );
  }
}

// -------------------------------------------------------------------

abstract class _BaseCrudService<M extends Jsonable> extends BaseService {
  _BaseCrudService(PocketBase client) : super(client);

  /// The factory function (eg. `fromJson()`) that will be used to
  /// decode the returned items from the crud endpoints.
  M itemFactoryFunc(Map<String, dynamic> json);

  Future<List<M>> _getFullList(
    String path, {
    int batch = 100,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final result = <M>[];

    Future<List<M>> request(int page) async {
      return _getList(
        path,
        page: page,
        perPage: batch,
        filter: filter,
        sort: sort,
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

  Future<ResultList<M>> _getList(
    String path, {
    int page = 1,
    int perPage = 30,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final params = Map<String, dynamic>.of(query);
    params["page"] = page;
    params["perPage"] = perPage;
    params["filter"] ??= filter;
    params["sort"] ??= sort;

    return client.send(path, query: params, headers: headers).then((data) {
      return ResultList<M>.fromJson(
        data as Map<String, dynamic>? ?? {},
        itemFactoryFunc,
      );
    });
  }

  Future<M> _getOne(
    String path, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(path, query: query, headers: headers)
        .then((data) => itemFactoryFunc(data as Map<String, dynamic>? ?? {}));
  }

  Future<M> _create(
    String path, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          path,
          method: "POST",
          body: body,
          query: query,
          files: files,
          headers: headers,
        )
        .then((data) => itemFactoryFunc(data as Map<String, dynamic>? ?? {}));
  }

  Future<M> _update(
    String path, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          path,
          method: "PATCH",
          body: body,
          query: query,
          files: files,
          headers: headers,
        )
        .then((data) => itemFactoryFunc(data as Map<String, dynamic>? ?? {}));
  }

  Future<void> _delete(
    String path, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      path,
      method: "DELETE",
      body: body,
      query: query,
      headers: headers,
    );
  }
}
