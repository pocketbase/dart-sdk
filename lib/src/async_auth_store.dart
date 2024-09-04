import "dart:convert";

import "auth_store.dart";
import "dtos/record_model.dart";
import "sync_queue.dart";

typedef SaveFunc = Future<void> Function(String data);
typedef ClearFunc = Future<void> Function();

/// AsyncAuthStore is a pluggable AuthStore implementation that
/// could be used with any external async persistent layer
/// (shared_preferences, hive, local file, etc.).
///
/// Below is an example using `SharedPreferences`:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
///
/// final store = AsyncAuthStore(
///   save:    (String data) async => prefs.setString('pb_auth', data),
///   initial: prefs.getString('pb_auth'),
/// );
///
/// final pb = PocketBase('http://example.com', authStore: store);
/// ```
class AsyncAuthStore extends AuthStore {
  /// Async function that is called every time when the auth
  /// store state needs to be persisted.
  late final SaveFunc saveFunc;

  /// An optional async function that is called every time when
  /// the auth store needs to be cleared.
  ///
  /// If not explicitly set, `saveFunc` with empty data will be used.
  late final ClearFunc? clearFunc;

  // encoded data keys
  final String _tokenKey = "token";
  final String _modelKey = "model";

  AsyncAuthStore({
    required SaveFunc save,
    String? initial, // initial data to load into the store
    ClearFunc? clear,
  }) {
    saveFunc = save;
    clearFunc = clear;

    _loadInitial(initial);
  }

  final _queue = SyncQueue();

  @override
  void save(
    String newToken,
    RecordModel? newRecord,
  ) {
    super.save(newToken, newRecord);

    final encoded = jsonEncode({_tokenKey: token, _modelKey: record});

    _queue.enqueue(() => saveFunc(encoded));
  }

  @override
  void clear() {
    super.clear();

    if (clearFunc == null) {
      _queue.enqueue(() => saveFunc(""));
    } else {
      _queue.enqueue(() => clearFunc!());
    }
  }

  void _loadInitial(String? initial) {
    if (initial == null || initial.isEmpty) {
      return;
    }

    var decoded = <String, dynamic>{};
    try {
      final raw = jsonDecode(initial);
      if (raw is Map<String, dynamic>) {
        decoded = raw;
      }
    } catch (_) {
      return;
    }

    final token = decoded[_tokenKey] as String? ?? "";

    final record =
        RecordModel.fromJson(decoded[_modelKey] as Map<String, dynamic>? ?? {});

    save(token, record);
  }
}
