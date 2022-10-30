import "../client.dart";
import "../sse/sse_client.dart";
import "../sse/sse_message.dart";
import "base_service.dart";

/// The definition of a realtime subscription callback function.
typedef SubscriptionFunc = void Function(SseMessage e);

/// The service that handles the **Realtime APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.realtime] should be used.
class RealtimeService extends BaseService {
  RealtimeService(PocketBase client) : super(client);

  SseClient? _sse;
  String _clientId = "";
  final _subscriptions = <String, SubscriptionFunc>{};

  /// Initialize the realtime connection (if not already)
  /// and register the provided subscription.
  Future<void> subscribe(
    String subscription,
    SubscriptionFunc callback,
  ) async {
    // register the subscription
    // (previous identical subscription is replaced)
    _subscriptions[subscription] = callback;

    // start a new sse connection
    if (_sse == null) {
      return _connect();
    }

    // otherwise - just persist the updated subscriptions
    if (_clientId.isNotEmpty) {
      return _submitSubscriptions();
    }
  }

  /// Unsubscribe from all subscriptions starting with the provided prefix.
  ///
  /// This method is no-op if there are no active subscriptions with
  /// the provided prefix.
  ///
  /// The related sse connection will be autoclosed if after the
  /// unsubscribe operation there are no active subscriptions left.
  Future<void> unsubscribeByPrefix(String prefix) async {
    final beforeLength = _subscriptions.length;

    // remove matching subscriptions
    _subscriptions.removeWhere((sub, func) {
      return sub.startsWith(prefix);
    });

    // no changes
    if (beforeLength == _subscriptions.length) {
      return;
    }

    // no more subscriptions -> close the sse connection
    if (_subscriptions.isEmpty) {
      return _disconnect();
    }

    // otherwise - notify the server about the subscription changes
    if (_clientId.isNotEmpty) {
      return _submitSubscriptions();
    }
  }

  /// Unsubscribe from a subscription.
  ///
  /// If the `subscription` argument is not set,
  /// then the client will unsubscribe from all registered subscriptions.
  ///
  /// The underlying sse connection will be autoclosed if after the
  /// unsubscribe operation there are no active subscriptions left.
  Future<void> unsubscribe([String subscription = ""]) async {
    if (subscription.isEmpty) {
      // remove all subscriptions
      _subscriptions.clear();
    } else if (_subscriptions.containsKey(subscription)) {
      _subscriptions.remove(subscription);
    } else {
      // not subscribed to the specified subscription
      return;
    }

    // no more subscriptions -> close the sse connection
    if (_subscriptions.isEmpty) {
      return _disconnect();
    }

    // otherwise - notify the server about the subscription changes
    if (_clientId.isNotEmpty) {
      return _submitSubscriptions();
    }
  }

  Future<void> _connect() async {
    _disconnect();

    final url = client.buildUrl("/api/realtime").toString();

    _sse = SseClient(url, onClose: _disconnect);

    // bind subscriptions listener
    _sse?.onMessage.listen((msg) {
      if (!_subscriptions.containsKey(msg.event)) {
        return;
      }

      _subscriptions[msg.event]?.call(msg);
    });

    // resubmit local subscriptions on first reconnect
    _sse?.onMessage.where((msg) => msg.event == "PB_CONNECT").listen((
      msg,
    ) {
      _clientId = msg.id;
      _submitSubscriptions();
    }, onError: (err) {
      _disconnect();
    });
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
