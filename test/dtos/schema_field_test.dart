import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("SchemaField", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "schema_id",
        "name": "schema_name",
        "type": "schema_type",
        "system": true,
        "required": false,
        "presentable": true,
        "options": {"a": 123},
      };

      final model = SchemaField.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
