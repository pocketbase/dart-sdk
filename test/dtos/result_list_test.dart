import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("ResultList", () {
    test("fromJson() and toJson()", () {
      final json = {
        "page": 2,
        "perPage": 20,
        "totalItems": 200,
        "totalPages": 10,
        "items": [
          {
            "id": "test_id",
            "created": "test_created",
            "updated": "test_updated",
            "collectionId": "test_collectionId",
            "collectionName": "test_collectionName",
            "expand": {
              "test": RecordModel({"id": "1"}).toJson(),
            },
            "a": 1,
            "b": "test",
            "c": true,
          }
        ],
      };

      final model = ResultList<RecordModel>.fromJson(
        json,
        RecordModel.fromJson,
      );

      expect(model.toJson(), json);
    });
  });
}
