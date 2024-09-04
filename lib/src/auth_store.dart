import "dart:async";
import "dart:convert";

import "./dtos/record_model.dart";

/// Event object that holds an AuthStore state.
class AuthStoreEvent {
  AuthStoreEvent(this.token, this.record);

  final String token;
  final RecordModel? record;

  @Deprecated("use record")
  dynamic get model => record as dynamic;

  @override
  String toString() => "token: $token\nrecord: $record";
}

/// Base authentication store management service that keep tracks of
/// the authenticated User/Admin model and its token.
class AuthStore {
  final _onChangeController = StreamController<AuthStoreEvent>.broadcast();

  String _token = "";
  RecordModel? _record;

  /// Returns the saved auth token (if any).
  String get token => _token;

  /// Returns the saved auth record (if any).
  RecordModel? get record => _record;

  @Deprecated("use record")
  dynamic get model => record as dynamic;

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

  /// Saves the provided [newToken] and [newRecord] auth data into the store.
  void save(String newToken, RecordModel? newRecord) {
    _token = newToken;
    _record = newRecord;

    _onChangeController.add(AuthStoreEvent(token, newRecord));
  }

  /// Clears the previously stored [token] and [record] auth data.
  void clear() {
    _token = "";
    _record = null;

    _onChangeController.add(AuthStoreEvent(token, record));
  }
}
