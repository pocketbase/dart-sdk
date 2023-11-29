import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("LogModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "created": "test_created",
        "updated": "test_updated",
        "level": -4,
        "message": "test_message",
        "data": {"a": 123},
      };

      final model = LogModel.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
