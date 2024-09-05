import "dart:async";
import "dart:convert";

import "package:http/http.dart" as http;

import "auth_store.dart";
import "client_exception.dart";
import "dtos/record_model.dart";
import "multipart_request.dart";
import "services/backup_service.dart";
import "services/batch_service.dart";
import "services/collection_service.dart";
import "services/file_service.dart";
import "services/health_service.dart";
import "services/log_service.dart";
import "services/realtime_service.dart";
import "services/record_service.dart";
import "services/settings_service.dart";

const bool isWeb = bool.fromEnvironment("dart.library.js_util");

/// The main PocketBase API client.
class PocketBase {
  /// The PocketBase backend base url address (eg. 'http://127.0.0.1:8090').
  String baseUrl;

  /// Optional language code (default to `en-US`) that will be sent
  /// with the requests to the server as `Accept-Language` header.
  String lang;

  /// An instance of the local [AuthStore] service.
  late final AuthStore authStore;

  @Deprecated("use collection('_superusers')")
  RecordService get admins => collection("_superusers");

  /// An instance of the service that handles the **Collection APIs**.
  late final CollectionService collections;

  /// An instance of the service that handles the **File APIs**.
  late final FileService files;

  /// An instance of the service that handles the **Realtime APIs**.
  ///
  /// This service is usually used with custom realtime actions.
  /// For records realtime subscriptions you can use the subscribe/unsubscribe
  /// methods available in the `collection()` RecordService.
  late final RealtimeService realtime;

  /// An instance of the service that handles the **Settings APIs**.
  late final SettingsService settings;

  /// An instance of the service that handles the **Log APIs**.
  late final LogService logs;

  /// An instance of the service that handles the **Health APIs**.
  late final HealthService health;

  /// The service that handles the **Backup and restore APIs**.
  late final BackupService backups;

  /// The underlying http client that will be used to send the request.
  /// This is used primarily for the unit tests.
  late final http.Client Function() httpClientFactory;

  /// Cache of all created RecordService instances.
  final _recordServices = <String, RecordService>{};

  PocketBase(
    this.baseUrl, {
    this.lang = "en-US",
    AuthStore? authStore,
    // used primarily for the unit tests
    http.Client Function()? httpClientFactory,
  }) {
    this.authStore = authStore ?? AuthStore();
    this.httpClientFactory = httpClientFactory ?? http.Client.new;

    collections = CollectionService(this);
    files = FileService(this);
    realtime = RealtimeService(this);
    settings = SettingsService(this);
    logs = LogService(this);
    health = HealthService(this);
    backups = BackupService(this);
  }

  /// Returns the RecordService associated to the specified collection.
  RecordService collection(String collectionIdOrName) {
    var service = _recordServices[collectionIdOrName];

    if (service == null) {
      // create and cache the service
      service = RecordService(this, collectionIdOrName);
      _recordServices[collectionIdOrName] = service;
    }

    return service;
  }

  /// Constructs a filter expression with placeholders populated from a map.
  ///
  /// Placeholder parameters are defined with the `{:paramName}` notation.
  ///
  /// The following parameter values are supported:
  /// - `String` (_single quotes are autoescaped_)
  /// - `num`
  /// - `bool`
  /// - `DateTime`
  /// - `null`
  /// - everything else is converted to a string using `jsonEncode()`
  ///
  /// Example:
  ///
  /// ```dart
  /// pb.collection("example").getList(filter: pb.filter(
  ///   "title ~ {:title} && created >= {:created}",
  ///   { "title": "example", "created": DateTime.now() },
  /// ));
  /// ```
  String filter(String expr, [Map<String, dynamic> query = const {}]) {
    if (query.isEmpty) {
      return expr;
    }

    query.forEach((key, value) {
      if (value == null || value is num || value is bool) {
        value = value.toString();
      } else if (value is DateTime) {
        value = "'${value.toUtc().toIso8601String().replaceFirst("T", " ")}'";
      } else if (value is String) {
        value = "'${value.replaceAll("'", "\\'")}'";
      } else {
        value = "'${jsonEncode(value).replaceAll("'", "\\'")}'";
      }
      expr = expr.replaceAll("{:$key}", value.toString());
    });

    return expr;
  }

  /// Legacy alias of `pb.files.getUrl()`.
  Uri getFileUrl(
    RecordModel record,
    String filename, {
    String? thumb,
    String? token,
    Map<String, dynamic> query = const {},
  }) {
    return files.getUrl(
      record,
      filename,
      thumb: thumb,
      token: token,
      query: query,
    );
  }

  /// Builds and returns a full request url by safely concatenating
  /// the provided path to the base url.
  Uri buildUrl(String path, [Map<String, dynamic> queryParameters = const {}]) {
    var url = baseUrl + (baseUrl.endsWith("/") ? "" : "/");

    if (path.isNotEmpty) {
      url += path.startsWith("/") ? path.substring(1) : path;
    }

    final query = _normalizeQueryParameters(queryParameters);

    return Uri.parse(url).replace(
      queryParameters: query.isNotEmpty ? query : null,
    );
  }

  /// Creates a new batch handler for sending multiple transactional
  /// create/update/upsert/delete collection requests in one network call.
  ///
  /// Example:
  ///
  /// ```dart
  /// final batch = await pb.createBatch();
  ///
  /// batch.collection('example1').create(body: { ... });
  /// batch.collection('example2').update('RECORD_ID', body: { ... });
  /// batch.collection('example3').delete('RECORD_ID');
  /// batch.collection('example4').upsert(body: { ... });
  ///
  /// await batch.send();
  /// ```
  BatchService createBatch() {
    return BatchService(this);
  }

  /// Sends a single HTTP request built with the current client configuration
  /// and the provided options.
  ///
  /// All response errors are normalized and wrapped in [ClientException].
  Future<T> send<T extends dynamic>(
    // ignore: lines_longer_than_80_chars
    // note: the optional generic type is to ensure that the expected response data type is returned
    //       the extends is to explicitly infer by default to dynamic
    String path, {
    String method = "GET",
    Map<String, String> headers = const {},
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
    List<http.MultipartFile> files = const [],
  }) async {
    http.BaseRequest request;

    final url = buildUrl(path, query);

    if (files.isEmpty) {
      request = _jsonRequest(method, url, headers: headers, body: body);
    } else {
      request = _multipartRequest(
        method,
        url,
        headers: headers,
        body: body,
        files: files,
      );
    }

    if (!headers.containsKey("Authorization") && authStore.isValid) {
      request.headers["Authorization"] = authStore.token;
    }

    if (!headers.containsKey("Accept-Language")) {
      request.headers["Accept-Language"] = lang;
    }

    // ensures that keepalive on web is disabled for now
    //
    // it is ignored anyway when using the default http.Cient on web
    // and it causing issues with the alternative fetch_client package
    // (see https://github.com/Zekfad/fetch_client/issues/6#issuecomment-1615936365)
    if (isWeb) {
      request.persistentConnection = false;
    }

    final requestClient = httpClientFactory();

    try {
      final response = await requestClient.send(request);
      final responseStr = await response.stream.bytesToString();

      dynamic responseData;
      try {
        responseData = responseStr.isNotEmpty ? jsonDecode(responseStr) : null;
      } catch (_) {
        // custom non-json response
        responseData = responseStr;
      }

      if (response.statusCode >= 400) {
        throw ClientException(
          url: url,
          statusCode: response.statusCode,
          response: responseData is Map<String, dynamic> ? responseData : {},
        );
      }

      return responseData as T;
    } catch (e) {
      // PocketBase API exception
      if (e is ClientException) {
        rethrow;
      }

      // http client exception (eg. connection abort)
      if (e is http.ClientException) {
        throw ClientException(
          url: e.uri,
          originalError: e,
          // @todo will need to be redefined once cancellation support is added
          isAbort: true,
        );
      }

      // anything else
      throw ClientException(url: url, originalError: e);
    } finally {
      requestClient.close();
    }
  }

  http.Request _jsonRequest(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
  }) {
    final request = http.Request(method, url);

    if (body.isNotEmpty) {
      request.body = jsonEncode(body);
    }

    if (headers.isNotEmpty) {
      request.headers.addAll(headers);
    }

    if (!headers.containsKey("Content-Type")) {
      request.headers["Content-Type"] = "application/json";
    }

    return request;
  }

  MultipartRequest _multipartRequest(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    List<http.MultipartFile> files = const [],
  }) {
    final request = MultipartRequest(method, url)
      ..files.addAll(files)
      ..headers.addAll(headers);

    request.fields["@jsonPayload"] = [jsonEncode(body)];

    return request;
  }

  Map<String, dynamic> _normalizeQueryParameters(
    Map<String, dynamic> parameters,
  ) {
    final result = <String, dynamic>{};

    parameters.forEach((key, value) {
      final normalizedValue = <String>[];

      // convert to List to normalize access
      if (value is! Iterable) {
        value = [value];
      }

      for (dynamic v in value) {
        if (v == null) {
          continue; // skip null query params
        }

        normalizedValue.add(v.toString());
      }

      if (normalizedValue.isNotEmpty) {
        result[key] = normalizedValue;
      }
    });

    return result;
  }
}
