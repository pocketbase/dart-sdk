import "../client.dart";
import "../dtos/record_model.dart";
import "base_crud_service.dart";

/// The service that handles the **Record APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.records] should be used.
class RecordService extends SubCrudService<RecordModel> {
  RecordService(PocketBase client) : super(client);

  @override
  String basePath(String sub) =>
      "/api/collections/${Uri.encodeComponent(sub)}/records";

  @override
  RecordModel itemFactoryFunc(Map<String, dynamic> json) =>
      RecordModel.fromJson(json);

  /// Builds and returns an absolute record file url.
  Uri getFileUrl(
    RecordModel record,
    String filename, {
    Map<String, dynamic> query = const {},
  }) {
    return client.buildUrl(
      "/api/files/${Uri.encodeComponent(record.collectionId)}/${Uri.encodeComponent(record.id)}/${Uri.encodeComponent(filename)}",
      query,
    );
  }
}
