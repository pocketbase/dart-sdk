import "../client.dart";
import "../dtos/collection_model.dart";
import "base_crud_service.dart";

/// The service that handles the **Collection APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.collections] should be used.
class CollectionService extends BaseCrudService<CollectionModel> {
  CollectionService(super.client);

  @override
  String get baseCrudPath => "/api/collections";

  @override
  CollectionModel itemFactoryFunc(Map<String, dynamic> json) =>
      CollectionModel.fromJson(json);

  /// Imports the provided collections.
  ///
  /// If [deleteMissing] is `true`, all local collections and schema fields,
  /// that are not present in the imported configuration, WILL BE DELETED
  /// (including their related records data)!
  Future<void> import(
    List<CollectionModel> collections, {
    bool deleteMissing = false,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["collections"] = collections;
    enrichedBody["deleteMissing"] = deleteMissing;

    return client.send(
      "$baseCrudPath/import",
      method: "PUT",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }
}
