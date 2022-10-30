import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("CollectionModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "type": "test_type",
        "created": "test_created",
        "updated": "test_updated",
        "name": "test_name",
        "schema": [
          {
            "id": "schema_id",
            "name": "schema_name",
            "type": "schema_type",
            "system": true,
            "required": false,
            "unique": false,
            "options": {"a": 123},
          },
        ],
        "system": true,
        "listRule": "test_listRule",
        "viewRule": null,
        "createRule": "test_createRule",
        "updateRule": "",
        "deleteRule": "test_deleteRule",
        "options": {"b": 123},
      };

      final model = CollectionModel.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
