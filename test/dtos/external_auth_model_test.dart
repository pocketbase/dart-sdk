import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("ExternalAuthModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "created": "test_created",
        "updated": "test_updated",
        "recordId": "test_recordId",
        "collectionId": "test_collectionId",
        "provider": "test_provider",
        "providerId": "test_providerId",
      };

      final model = ExternalAuthModel.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
