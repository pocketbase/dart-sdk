import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AdminAuth", () {
    test("fromJson() and toJson()", () {
      final json = {
        "token": "test_token",
        "admin": {
          "id": "test_id",
          "created": "test_created",
          "updated": "test_updated",
          "avatar": 123,
          "email": "test_email",
          "lastResetSentAt": "",
        },
      };

      final model = AdminAuth.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
