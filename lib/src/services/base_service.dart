import "../client.dart";

abstract class BaseService {
  final PocketBase _client;

  PocketBase get client => _client;

  BaseService(this._client);
}

// assert helper to avoid throwing an exception and instead always
// fallback to the provided type in case the server for some reason
// (e.g. proxy) returns a non-standard PocketBase response.
T assertAs<T>(dynamic val, T fallback) {
  if (val is T) {
    return val;
  }

  return fallback;
}
