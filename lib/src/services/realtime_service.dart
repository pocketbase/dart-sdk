import "dart:async";

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
  RealtimeService(PocketBase client) : super(client);

  SseClient? _sse;
  String _clientId = "";
  final _subscriptions = <String, List<SubscriptionFunc>>{};

  // Returns the established SSE connection client id (if any).
  String get clientId => _clientId;

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
    SubscriptionFunc listener,
  ) async {
    if (!_subscriptions.containsKey(topic)) {
      _subscriptions[topic] = [];
    }
    _subscriptions[topic]?.add(listener);

    // start a new sse connection
    if (_sse == null) {
      await _connect();
    } else if (_clientId.isNotEmpty && _subscriptions[topic]?.length == 1) {
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
    if (topic.isEmpty) {
      // remove all subscriptions
      _subscriptions.clear();
    } else if (_subscriptions.containsKey(topic)) {
      _subscriptions.remove(topic);
    } else {
      // not subscribed to the specified topic
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
    _subscriptions.removeWhere((topic, func) {
      return topic.startsWith(topicPrefix);
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
    if (_subscriptions[topic]?.isEmpty ?? true) {
      return; // nothing to unsubscribe from
    }

    final beforeLength = _subscriptions[topic]?.length ?? 0;

    _subscriptions[topic]?.removeWhere((fn) => fn == listener);

    // no changes
    if (beforeLength == (_subscriptions[topic]?.length ?? 0)) {
      return;
    }

    // no other subscriptions -> close the sse connection
    if (!_hasNonEmptyTopic()) {
      return _disconnect();
    }

    // otherwise - notify the server about the subscription changes
    // (if there are no other subscriptions in the topic)
    if (_clientId.isNotEmpty && (_subscriptions[topic]?.isEmpty ?? true)) {
      return _submitSubscriptions();
    }
  }

  bool _hasNonEmptyTopic() {
    for (final topic in _subscriptions.keys) {
      if (_subscriptions[topic]?.isNotEmpty ?? false) {
        return true; // has at least one non-empty topic
      }
    }

    return false;
  }

  Future<void> _connect() {
    _disconnect();

    final completer = Completer<void>();

    final url = client.buildUrl("/api/realtime").toString();

    _sse = SseClient(
      url,
      httpClientFactory: client.httpClientFactory,
      onClose: () {
        _disconnect();

        if (!completer.isCompleted) {
          completer
              .completeError(StateError("failed to establish SSE connection"));
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
