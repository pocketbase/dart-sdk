import "../client.dart";

abstract class BaseService {
  final PocketBase _client;

  PocketBase get client => _client;

  BaseService(this._client);
}
