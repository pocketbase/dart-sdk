import "../client.dart";
import "../dtos/collection_model.dart";
import "base_crud_service.dart";

/// The service that handles the **Collection APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.collections] should be used.
class CollectionService extends CrudService<CollectionModel> {
  CollectionService(PocketBase client) : super(client);

  @override
  String get basePath => "/api/collections";

  @override
  CollectionModel itemFactoryFunc(Map<String, dynamic> json) =>
      CollectionModel.fromJson(json);
}
