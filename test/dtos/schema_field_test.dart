import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("CollectionField", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "schema_id",
        "name": "schema_name",
        "type": "schema_type",
        "system": true,
        "required": false,
        "presentable": true,
        "example": {"a": 123},
      };

      final model = CollectionField.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
