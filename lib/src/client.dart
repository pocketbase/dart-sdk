import "dart:async";
import "dart:convert";

import "package:http/http.dart" as http;

import "auth_store.dart";
import "cancel_token.dart";
import "client_exception.dart";
import "dtos/record_model.dart";
import "multipart_request.dart";
import "services/backup_service.dart";
import "services/batch_service.dart";
import "services/collection_service.dart";
import "services/cron_service.dart";
import "services/file_service.dart";
import "services/health_service.dart";
import "services/log_service.dart";
import "services/realtime_service.dart";
import "services/record_service.dart";
import "services/settings_service.dart";

const bool isWeb = bool.fromEnvironment("dart.library.js_util");

/// The main PocketBase API client.
class PocketBase {
  @Deprecated("use baseURL")
  String get baseUrl => baseURL;

  @Deprecated("use baseURL")
  set baseUrl(String v) => baseURL = v;

  /// The PocketBase backend base url address (eg. 'http://127.0.0.1:8090').
  String baseURL;

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

  /// The service that handles the **Cron APIs**.
  late final CronService crons;

  /// The underlying http client that will be used to send the request.
  /// This is used primarily for the unit tests.
  late http.Client Function() httpClientFactory;

  /// Cache of all created RecordService instances.
  final _recordServices = <String, RecordService>{};

  /// Map of active cancel tokens for auto-cancellation.
  final _cancelTokens = <String, CancelToken>{};

  /// Whether auto-cancellation of duplicate requests is enabled.
  bool _enableAutoCancellation = true;

  /// The shared HTTP client instance that is used when the
  /// `reuseHTTPClient` constructor argument is set.
  http.Client? _sharedHTTPClient;

  /// Holds the close state of the client.
  bool _closed = false;

  PocketBase(
    this.baseURL, {
    this.lang = "en-US",
    AuthStore? authStore,

    /// Initializes a single HTTP client and reuses it for all requests,
    /// in order to improve the performance by keeping a persistent connection.
    ///
    /// NB! If enabled you'll need to call `pb.close()` once you are done
    /// working with the client.
    bool reuseHTTPClient = false,

    /// Optional factory to load custom `http.Client` implementation.
    http.Client Function()? httpClientFactory,
  }) {
    this.authStore = authStore ?? AuthStore();
    this.httpClientFactory = httpClientFactory ?? http.Client.new;

    if (reuseHTTPClient) {
      _sharedHTTPClient = this.httpClientFactory();
    }

    collections = CollectionService(this);
    files = FileService(this);
    realtime = RealtimeService(this);
    settings = SettingsService(this);
    logs = LogService(this);
    health = HealthService(this);
    backups = BackupService(this);
    crons = CronService(this);
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

  /// Globally enable or disable auto cancellation for pending duplicated 
  /// requests.
  /// 
  /// When enabled (default), sending multiple requests to the same endpoint
  /// will automatically cancel the previous pending requests.
  void autoCancellation(bool enable) {
    _enableAutoCancellation = enable;
  }

  /// Cancels a single request by its cancellation key.
  /// 
  /// The cancellation key is usually the HTTP method + path,
  /// or a custom key specified in the request options.
  void cancelRequest(String requestKey) {
    final token = _cancelTokens[requestKey];
    if (token != null && !token.isCancelled) {
      token.cancel("Request was cancelled manually");
      _cancelTokens.remove(requestKey);
    }
  }

  /// Cancels all pending requests.
  void cancelAllRequests() {
    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel("All requests were cancelled");
      }
    }
    _cancelTokens.clear();
  }

  /// Note: this method needs to be called only when the PocketBase
  /// client instance is created with the `reuseHTTPClient` option.
  ///
  /// Closes the shared HTTP client and cleans up any resources
  /// associated with it.
  ///
  /// Once closed, the client instance should be discarded and no
  /// further requests can be made with it.
  ///
  /// Calling [close] multiple times is allowed and does nothing.
  /// If [close] is called while other asynchronous methods are running,
  /// the behavior is undefined.
  void close() {
    if (!_closed && _sharedHTTPClient != null) {
      _sharedHTTPClient?.close();
      _closed = true;
    }
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

  @Deprecated("use pb.files.getURL()")
  Uri getFileUrl(
    RecordModel record,
    String filename, {
    String? thumb,
    String? token,
    Map<String, dynamic> query = const {},
  }) {
    return files.getURL(
      record,
      filename,
      thumb: thumb,
      token: token,
      query: query,
    );
  }

  @Deprecated("use pb.buildURL()")
  Uri buildUrl(String path, [Map<String, dynamic> queryParameters = const {}]) {
    return buildURL(path, queryParameters);
  }

  /// Builds and returns a full request url by safely concatenating
  /// the provided path to the base url.
  Uri buildURL(String path, [Map<String, dynamic> queryParameters = const {}]) {
    var url = baseURL + (baseURL.endsWith("/") ? "" : "/");

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
  /// 
  /// [requestKey] can be used to control auto-cancellation:
  /// - If not specified: use default auto-cancellation based on method+path
  /// - If specified: use custom key for auto-cancellation
  /// - If explicitly set to `null`: disable auto-cancellation for this request
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
    CancelToken? cancelToken,
    Object? requestKey = const Object(), // Use Object() as sentinel
  }) async {
    final url = buildURL(path, query);

    if (_closed) {
      throw ClientException(
        url: url,
        originalError: StateError("Client is closed"),
      );
    }

    // Handle auto-cancellation
    var effectiveCancelToken = cancelToken;
    
    // Auto-cancellation logic:
    // - If requestKey is explicitly null: disable auto-cancellation
    // - If requestKey is provided (string): use custom key 
    // - If requestKey is not specified: use default key if enabled
    var shouldUseAutoCancellation = false;
    String? autoCancelKey;
    
    if (requestKey == null) {
      // Explicitly disabled auto-cancellation
      shouldUseAutoCancellation = false;
    } else if (requestKey is String) {
      // Custom requestKey provided
      shouldUseAutoCancellation = true;
      autoCancelKey = requestKey;
    } else if (_enableAutoCancellation) {
      // Use default key (requestKey is the sentinel Object)
      shouldUseAutoCancellation = true;
      autoCancelKey = "$method $path";
    }
    
    if (shouldUseAutoCancellation && autoCancelKey != null) {
      // Cancel previous request with the same key
      final existingToken = _cancelTokens[autoCancelKey];
      if (existingToken != null && !existingToken.isCancelled) {
        existingToken.cancel("Request was auto-cancelled");
      }
      
      // Create new token for this request
      final autoCancelToken = CancelToken();
      _cancelTokens[autoCancelKey] = autoCancelToken;
      
      // Combine with user-provided token if any
      effectiveCancelToken = cancelToken != null 
          ? cancelToken.combine(autoCancelToken)
          : autoCancelToken;
    }

    http.BaseRequest request;

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

    final requestClient = _sharedHTTPClient ?? httpClientFactory();

    try {
      // Check for cancellation before sending
      effectiveCancelToken?.throwIfCancelled();

      final response = await _sendWithCancellation(
        requestClient, 
        request, 
        effectiveCancelToken,
      );
      
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
    } on CancellationException catch (e) {
      throw ClientException(
        url: url,
        isAbort: true,
        originalError: e,
      );
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
      // Clean up cancel token if it was auto-generated
      if (shouldUseAutoCancellation && autoCancelKey != null) {
        _cancelTokens.remove(autoCancelKey);
      }
      
      // shared clients must be closed manually
      if (_sharedHTTPClient == null) {
        requestClient.close();
      }
    }
  }

  /// Sends an HTTP request with cancellation support.
  Future<http.StreamedResponse> _sendWithCancellation(
    http.Client client,
    http.BaseRequest request,
    CancelToken? cancelToken,
  ) async {
    if (cancelToken == null) {
      return client.send(request);
    }

    final responseCompleter = Completer<http.StreamedResponse>();
    late StreamSubscription<void> cancelSubscription;

    // Set up cancellation listener
    cancelSubscription = cancelToken.whenCancelled.asStream().listen((_) {
      if (!responseCompleter.isCompleted) {
        responseCompleter.completeError(
          CancellationException(cancelToken.reason ?? "Request was cancelled"),
        );
      }
    });

    // Send the request
    client.send(request).then((response) {
      cancelSubscription.cancel();
      if (!responseCompleter.isCompleted) {
        responseCompleter.complete(response);
      }
    }).catchError((Object error) {
      cancelSubscription.cancel();
      if (!responseCompleter.isCompleted) {
        responseCompleter.completeError(error);
      }
    }).ignore();

    return responseCompleter.future;
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
