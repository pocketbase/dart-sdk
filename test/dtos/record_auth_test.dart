import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("RecordAuth", () {
    test("fromJson() and toJson()", () {
      final json = {
        "token": "test_token",
        "record": {
          "id": "test_id",
          "created": "test_created",
          "updated": "test_updated",
          "collectionId": "test_collectionId",
          "collectionName": "test_collectionName",
          "expand": {
            "test": RecordModel({"id": "123"}).toJson(),
          },
          "a": 1,
        },
        "meta": {"test": 123},
      };

      final model = RecordAuth.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
