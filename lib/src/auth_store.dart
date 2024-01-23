import "dart:async";
import "dart:convert";

/// Event object that holds an AuthStore state.
class AuthStoreEvent {
  AuthStoreEvent(this.token, this.model);

  final String token;
  final Object? /* RecordModel|AdminModel|null */ model;

  @override
  String toString() => "token: $token\nmodel: $model";
}

/// Base authentication store management service that keep tracks of
/// the authenticated User/Admin model and its token.
class AuthStore {
  String _token = "";
  Object? /* RecordModel|AdminModel|null */ _model;
  final _onChangeController = StreamController<AuthStoreEvent>.broadcast();

  /// Returns the saved auth token (if any).
  String get token => _token;

  /// Returns the saved auth model (if any).
  Object? /* RecordModel|AdminModel|null */ get model => _model;

  /// Stream that gets triggered on each auth store change
  /// (aka. on [save()] and [clear()] call).
  Stream<AuthStoreEvent> get onChange => _onChangeController.stream;

  /// Loosely checks if the current AuthStore has valid auth data
  /// (eg. whether the token is expired or not).
  bool get isValid {
    final parts = token.split(".");
    if (parts.length != 3) {
      return false;
    }

    final tokenPart = base64.normalize(parts[1]);
    final data = jsonDecode(utf8.decode(base64Decode(tokenPart)))
        as Map<String, dynamic>;

    final exp = data["exp"] is int
        ? data["exp"] as int
        : (int.tryParse(data["exp"].toString()) ?? 0);

    return exp > (DateTime.now().millisecondsSinceEpoch / 1000);
  }

  /// Saves the provided [newToken] and [newModel] auth data into the store.
  void save(
    String newToken,
    Object? /* RecordModel|AdminModel|null */ newModel,
  ) {
    _token = newToken;
    _model = newModel;

    _onChangeController.add(AuthStoreEvent(token, model));
  }

  /// Clears the previously stored [token] and [model] auth data.
  void clear() {
    _token = "";
    _model = null;

    _onChangeController.add(AuthStoreEvent(token, model));
  }
}
