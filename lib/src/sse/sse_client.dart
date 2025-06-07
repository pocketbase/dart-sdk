import "dart:async";
import "dart:convert";

import "package:http/http.dart" as http;

import "../client_exception.dart";

import "sse_message.dart";

/// Very rudimentary streamed response http client wrapper compatible
/// with the SSE message format.
///
/// The client supports auto reconnect based on the `retry` event message value
/// (default to max 5 attempts with 5s cool down in between).
///
/// Example usage:
///
/// ```dart
/// final sse = SseClient("https://example.com")
///
/// // subscribe to any message
/// sse.onMessage.listen((msg) {
///   print(msg);
/// });
///
/// // subscribe to specific event(s) only
/// sse.onMessage.where((msg) => msg.event == "PB_CONNECT").listen((msg) {
///   print(msg);
/// });
///
/// // close the connection and clean up any resources associated with it
/// sse.close();
/// ```
class SseClient {
  /// List with default stepped retry timeouts (in ms).
  static const List<int> defaultRetryTimeouts = [
    200,
    300,
    500,
    1000,
    1200,
    1500,
    2000,
  ];

  Timer? _retryTimer;
  int _retryAttempts = 0;
  num _maxRetry = double.infinity;

  /// Indicates whether the client was closed.
  bool get isClosed => _isClosed;
  bool _isClosed = false;

  /// Callback function that is triggered on client close.
  late final void Function()? _onClose;

  /// Callback function that is triggered on each error connect attempt.
  late final void Function(dynamic err)? _onError;

  /// The local streamed http response subscription.
  StreamSubscription<String>? _responseStreamSubscription;

  /// The stream where you"ll receive the parsed SSE event messages.
  Stream<SseMessage> get onMessage => _messageStreamController.stream;
  final _messageStreamController = StreamController<SseMessage>.broadcast();

  /// The regex used to parse a single line of the streamed response message.
  final _lineRegex = RegExp(r"^(\w+)[\s\:]+(.*)?$");

  final String _url;

  late final http.Client _httpClient;

  /// Initializes the client and connects to the provided url.
  SseClient(
    this._url, {
    num maxRetry = double.infinity,
    void Function()? onClose,
    void Function(dynamic err)? onError,

    /// The underlying http client that will be used to send the request.
    /// This is used primarily for the unit tests.
    http.Client Function()? httpClientFactory,
  }) {
    _maxRetry = maxRetry;
    _onClose = onClose;
    _onError = onError;
    _httpClient = httpClientFactory?.call() ?? http.Client();
    _init();
  }

  /// Closes the client and cleans up any resources associated with it.
  ///
  /// The method is also called internally on disconnect after
  /// all allowed retry attempts have failed.
  ///
  /// NB! After calling this method the client cannot be used anymore.
  void close() {
    if (isClosed) {
      return; // already closed
    }

    _isClosed = true;

    _retryTimer?.cancel();

    _responseStreamSubscription?.cancel();

    if (!_messageStreamController.isClosed) {
      _messageStreamController.close();
    }

    _httpClient.close();

    _onClose?.call();
  }

  void _init() async {
    if (isClosed) {
      return; // already closed
    }

    var sseMessage = SseMessage();

    final url = Uri.parse(_url);
    final request = http.Request("GET", url);
    try {
      final response = await _httpClient.send(request);

      if (response.statusCode >= 400) {
        final responseStr = await response.stream.bytesToString();
        final responseData = responseStr != "" ? jsonDecode(responseStr) : null;
        throw ClientException(
          url: url,
          statusCode: response.statusCode,
          response: responseData is Map<String, dynamic> ? responseData : {},
        );
      }

      // resets
      _retryAttempts = 0;
      sseMessage = SseMessage();
      await _responseStreamSubscription?.cancel();

      _responseStreamSubscription = response.stream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())
          .listen(
        (line) {
          // message end detected
          if (line.isEmpty) {
            _messageStreamController.add(sseMessage);
            sseMessage = SseMessage(); // reset for the next chunk
            return;
          }

          final match = _lineRegex.firstMatch(line);
          if (match == null) {
            // ignore invalid lines
            // (some servers may send a different formatted line as a ping)
            return;
          }

          final field = match.group(1) ?? "";
          final value = match.group(2) ?? "";

          if (field == "id") {
            sseMessage.id = value;
            return;
          }

          if (field == "event") {
            sseMessage.event = value;
            return;
          }

          if (field == "retry") {
            sseMessage.retry = int.tryParse(value) ?? 0;
            return;
          }

          if (field == "data") {
            sseMessage.data = value;
            return;
          }
        },
        onError: (dynamic err) {
          // usually triggered on abruptly connection termination
          // (eg. when the server goes down)
          _onError?.call(err);
          _reconnect(sseMessage.retry);
        },
        onDone: () {
          // usually triggered on graceful connection termination
          // (eg. when the server stops streaming in case on idle client)
          _onError?.call(null);
          _reconnect(sseMessage.retry);
        },
      );
    } catch (err) {
      // most likely the client failed to establish a connection with the server
      _onError?.call(err);
      _reconnect(sseMessage.retry);
    }
  }

  void _reconnect([int retryTimeout = 0]) {
    if (_retryAttempts >= _maxRetry) {
      // no more retries
      close();
      return;
    }

    if (retryTimeout <= 0) {
      if (_retryAttempts > defaultRetryTimeouts.length - 1) {
        retryTimeout = defaultRetryTimeouts.last;
      } else {
        retryTimeout = defaultRetryTimeouts[_retryAttempts];
      }
    }

    // cancel previous timer (if any)
    _retryTimer?.cancel();

    _retryTimer = Timer(Duration(milliseconds: retryTimeout), () {
      _retryAttempts++;
      _init();
    });
  }
}
