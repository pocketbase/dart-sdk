import "package:http/http.dart" as http;

import "../client.dart";
import "../dtos/batch_result.dart";
import "base_service.dart";

/// The service that handles the **Batch/transactional APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.createBatch()] should be used.
class BatchService extends BaseService {
  final List<_BatchRequest> _requests = [];
  final Map<String, SubBatchService> _subs = {};
  final dummyClient = PocketBase("/");

  BatchService(super.client);

  /// Starts constructing a batch request entry for the specified collection.
  SubBatchService collection(String collectionIdOrName) {
    var subService = _subs[collectionIdOrName];

    if (subService == null) {
      subService = SubBatchService(this, collectionIdOrName);
      _subs[collectionIdOrName] = subService;
    }

    return subService;
  }

  /// Sends the batch requests.
  Future<List<BatchResult>> send({
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final files = <http.MultipartFile>[];
    final jsonBody = <Map<String, dynamic>>[];

    for (var i = 0; i < _requests.length; i++) {
      final req = _requests[i];

      jsonBody.add({
        "method": req.method,
        "url": req.url,
        "headers": req.headers,
        "body": req.body,
      });

      for (final reqFile in req.files) {
        // note: MultipartFile doesn't allow changing the field name
        files.add(http.MultipartFile(
          "requests.$i.${reqFile.field}",
          reqFile.finalize(),
          reqFile.length,
          filename: reqFile.filename,
          contentType: reqFile.contentType,
        ));
      }
    }

    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["requests"] = jsonBody;

    return client
        .send<List<dynamic>>(
          "/api/batch",
          method: "POST",
          files: files,
          headers: headers,
          query: query,
          body: enrichedBody,
        )
        .then((data) => data
            .map((elem) =>
                BatchResult.fromJson(elem as Map<String, dynamic>? ?? {}))
            .toList());
  }
}

class SubBatchService {
  final BatchService _batch;
  final String _collectionIdOrName;

  SubBatchService(this._batch, this._collectionIdOrName);

  /// Registers a record upsert request into the current batch queue.
  ///
  /// The request will be executed as update if `bodyParams` have a
  /// valid existing record `id` value, otherwise - create.
  void upsert({
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

    final request = _BatchRequest(
      method: "PUT",
      files: files,
      url: _batch.dummyClient
          .buildURL(
            "/api/collections/${Uri.encodeComponent(_collectionIdOrName)}/records",
            enrichedQuery,
          )
          .toString(),
      headers: headers,
      body: body,
    );

    _batch._requests.add(request);
  }

  /// Registers a record create request into the current batch queue.
  void create({
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

    final request = _BatchRequest(
      method: "POST",
      files: files,
      url: _batch.dummyClient
          .buildURL(
            "/api/collections/${Uri.encodeComponent(_collectionIdOrName)}/records",
            enrichedQuery,
          )
          .toString(),
      headers: headers,
      body: body,
    );

    _batch._requests.add(request);
  }

  /// Registers a record update request into the current batch queue.
  void update(
    String recordId, {
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

    final request = _BatchRequest(
      method: "PATCH",
      files: files,
      url: _batch.dummyClient
          .buildURL(
            "/api/collections/${Uri.encodeComponent(_collectionIdOrName)}/records/${Uri.encodeComponent(recordId)}",
            enrichedQuery,
          )
          .toString(),
      headers: headers,
      body: body,
    );

    _batch._requests.add(request);
  }

  /// Registers a record delete request into the current batch queue.
  void delete(
    String recordId, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final request = _BatchRequest(
      method: "DELETE",
      url: _batch.dummyClient
          .buildURL(
            "/api/collections/${Uri.encodeComponent(_collectionIdOrName)}/records/${Uri.encodeComponent(recordId)}",
            query,
          )
          .toString(),
      headers: headers,
      body: body,
    );

    _batch._requests.add(request);
  }
}

class _BatchRequest {
  String method;
  String url;
  Map<String, String> headers;
  Map<String, dynamic> body;
  List<http.MultipartFile> files;

  _BatchRequest({
    String? method,
    String? url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    List<http.MultipartFile>? files,
  })  : method = method ?? "",
        url = url ?? "",
        headers = headers ?? {},
        body = body ?? {},
        files = files ?? [];
}
