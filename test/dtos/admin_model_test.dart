import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AdminModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "created": "test_created",
        "updated": "test_updated",
        "avatar": 123,
        "email": "test_email",
      };

      final model = AdminModel.fromJson(json);

      // to json
      expect(model.toJson(), json);
    });
  });
}
