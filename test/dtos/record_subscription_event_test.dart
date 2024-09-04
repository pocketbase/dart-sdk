import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("RecordSubscriptionEvent", () {
    test("fromJson() and toJson()", () {
      final json = {
        "action": "test_action",
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
      };

      final model = RecordSubscriptionEvent.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
