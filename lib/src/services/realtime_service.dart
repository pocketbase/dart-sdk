import "dart:async";
import "dart:convert";

import "../client.dart";
import "../sse/sse_client.dart";
import "../sse/sse_message.dart";
import "base_service.dart";

/// The definition of a realtime subscription callback function.
typedef SubscriptionFunc = void Function(SseMessage e);
typedef UnsubscribeFunc = Future<void> Function();

/// The service that handles the **Realtime APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.realtime] should be used.
class RealtimeService extends BaseService {
  RealtimeService(super.client);

  SseClient? _sse;
  String _clientId = "";
  final _subscriptions = <String, List<SubscriptionFunc>>{};

  /// Returns the established SSE connection client id (if any).
  String get clientId => _clientId;

  /// An optional hook that is invoked when the realtime client disconnects
  /// either when unsubscribing from all subscriptions or when the
  /// connection was interrupted or closed by the server.
  ///
  /// It receives the subscriptions map before the disconnect
  /// (could be used to determine whether the disconnect was caused by
  /// unsubscribing or network/server error).
  ///
  /// If you want to listen for the opposite, aka. when the client
  /// connection is established, subscribe to the `PB_CONNECT` event.
  void Function(Map<String, List<SubscriptionFunc>>)? onDisconnect;

  /// Register the subscription listener.
  ///
  /// You can subscribe multiple times to the same topic.
  ///
  /// If the SSE connection is not started yet,
  /// this method will also initialize it.
  ///
  /// Here is an example listening to the connect/reconnect events:
  ///
  /// ```dart
  /// pb.realtime.subscribe("PB_CONNECT", (e) {
  ///   print("Connected: $e");
  /// });
  /// ```
  Future<UnsubscribeFunc> subscribe(
    String topic,
    SubscriptionFunc listener, {
    String? expand,
    String? filter,
    String? fields,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) async {
    var key = topic;

    // merge query parameters
    final enrichedQuery = Map<String, dynamic>.of(query);
    if (expand?.isNotEmpty ?? false) {
      enrichedQuery["expand"] ??= expand;
    }
    if (filter?.isNotEmpty ?? false) {
      enrichedQuery["filter"] ??= filter;
    }
    if (fields?.isNotEmpty ?? false) {
      enrichedQuery["fields"] ??= fields;
    }

    // serialize and append the topic options (if any)
    final options = <String, dynamic>{};
    if (enrichedQuery.isNotEmpty) {
      options["query"] = enrichedQuery;
    }
    if (headers.isNotEmpty) {
      options["headers"] = headers;
    }
    if (options.isNotEmpty) {
      final encoded =
          "options=${Uri.encodeQueryComponent(jsonEncode(options))}";
      key += (key.contains("?") ? "&" : "?") + encoded;
    }

    if (!_subscriptions.containsKey(key)) {
      _subscriptions[key] = [];
    }
    _subscriptions[key]?.add(listener);

    // start a new sse connection
    if (_sse == null) {
      await _connect();
    } else if (_clientId.isNotEmpty && _subscriptions[key]?.length == 1) {
      // otherwise - just persist the updated subscriptions
      // (if it is the first for the topic)
      await _submitSubscriptions();
    }

    return () async {
      return unsubscribeByTopicAndListener(topic, listener);
    };
  }

  /// Unsubscribe from all subscription listeners with the specified topic.
  ///
  /// If [topic] is not set, then this method will unsubscribe
  /// from all active subscriptions.
  ///
  /// This method is no-op if there are no active subscriptions.
  ///
  /// The related sse connection will be autoclosed if after the
  /// unsubscribe operation there are no active subscriptions left.
  Future<void> unsubscribe([String topic = ""]) async {
    var needToSubmit = false;

    if (topic.isEmpty) {
      // remove all subscriptions
      _subscriptions.clear();
    } else {
      final subs = _getSubscriptionsByTopic(topic);

      for (final key in subs.keys) {
        _subscriptions.remove(key);
        needToSubmit = true;
      }
    }

    // no other subscriptions -> close the sse connection
    if (!_hasNonEmptyTopic()) {
      return _disconnect();
    }

    // otherwise - notify the server about the subscription changes
    if (_clientId.isNotEmpty && needToSubmit) {
      return _submitSubscriptions();
    }
  }

  /// Unsubscribe from all subscription listeners starting with
  /// the specified topic prefix.
  ///
  /// This method is no-op if there are no active subscriptions
  /// with the specified topic prefix.
  ///
  /// The related sse connection will be autoclosed if after the
  /// unsubscribe operation there are no active subscriptions left.
  Future<void> unsubscribeByPrefix(String topicPrefix) async {
    final beforeLength = _subscriptions.length;

    // remove matching subscriptions
    _subscriptions.removeWhere((key, func) {
      // "?" so that it can be used as end delimiter for the prefix
      return "$key?".startsWith(topicPrefix);
    });

    // no changes
    if (beforeLength == _subscriptions.length) {
      return;
    }

    // no other subscriptions -> close the sse connection
    if (!_hasNonEmptyTopic()) {
      return _disconnect();
    }

    // otherwise - notify the server about the subscription changes
    if (_clientId.isNotEmpty) {
      return _submitSubscriptions();
    }
  }

  /// Unsubscribe from all subscriptions matching the specified topic
  /// and listener function.
  ///
  /// This method is no-op if there are no active subscription with
  /// the specified topic and listener.
  ///
  /// The related sse connection will be autoclosed if after the
  /// unsubscribe operation there are no active subscriptions left.
  Future<void> unsubscribeByTopicAndListener(
    String topic,
    SubscriptionFunc listener,
  ) async {
    var needToSubmit = false;

    final subs = _getSubscriptionsByTopic(topic);

    for (final key in subs.keys) {
      if (_subscriptions[key]?.isEmpty ?? true) {
        continue; // nothing to unsubscribe from
      }

      final beforeLength = _subscriptions[key]?.length ?? 0;

      _subscriptions[key]?.removeWhere((fn) => fn == listener);

      final afterLength = _subscriptions[key]?.length ?? 0;

      // no changes
      if (beforeLength == afterLength) {
        continue;
      }

      // mark for subscriptions change submit if there are no other listeners
      if (!needToSubmit && afterLength == 0) {
        needToSubmit = true;
      }
    }

    // no other subscriptions -> close the sse connection
    if (!_hasNonEmptyTopic()) {
      return _disconnect();
    }

    // otherwise - notify the server about the subscription changes
    // (if there are no other subscriptions in the topic)
    if (_clientId.isNotEmpty && needToSubmit) {
      return _submitSubscriptions();
    }
  }

  Map<String, List<SubscriptionFunc>> _getSubscriptionsByTopic(String topic) {
    final result = <String, List<SubscriptionFunc>>{};

    // "?" so that it can be used as end delimiter for the topic
    topic = topic.contains("?") ? topic : "$topic?";

    _subscriptions.forEach((key, value) {
      if ("$key?".startsWith(topic)) {
        result[key] = value;
      }
    });

    return result;
  }

  bool _hasNonEmptyTopic() {
    for (final key in _subscriptions.keys) {
      if (_subscriptions[key]?.isNotEmpty ?? false) {
        return true; // has at least one listener
      }
    }

    return false;
  }

  Future<void> _connect() {
    _disconnect();

    final completer = Completer<void>();

    final url = client.buildURL("/api/realtime").toString();

    _sse = SseClient(
      url,
      httpClientFactory: client.httpClientFactory,
      onClose: () {
        if (_clientId.isNotEmpty && onDisconnect != null) {
          onDisconnect?.call(_subscriptions);
        }

        _disconnect();

        if (!completer.isCompleted) {
          completer
              .completeError(StateError("failed to establish SSE connection"));
        }
      },
      onError: (err) {
        if (_clientId.isNotEmpty && onDisconnect != null) {
          _clientId = "";
          onDisconnect?.call(_subscriptions);
        }
      },
    );

    // bind subscriptions listener
    _sse?.onMessage.listen((msg) {
      if (!_subscriptions.containsKey(msg.event)) {
        return;
      }

      _subscriptions[msg.event]?.forEach((fn) {
        fn.call(msg);
      });
    });

    // resubmit local subscriptions on first reconnect
    _sse?.onMessage.where((msg) => msg.event == "PB_CONNECT").listen((
      msg,
    ) async {
      _clientId = msg.id;
      await _submitSubscriptions();

      if (!completer.isCompleted) {
        completer.complete();
      }
    }, onError: (dynamic err) {
      _disconnect();

      if (!completer.isCompleted) {
        completer.completeError(
          err is Object
              ? err
              : StateError("failed to establish SSE connection"),
        );
      }
    });

    return completer.future;
  }

  void _disconnect() {
    _sse?.close();
    _sse = null;
    _clientId = "";
  }

  Future<void> _submitSubscriptions() {
    return client.send(
      "/api/realtime",
      method: "POST",
      body: {
        "clientId": _clientId,
        "subscriptions": _subscriptions.keys.toList(),
      },
    );
  }
}
