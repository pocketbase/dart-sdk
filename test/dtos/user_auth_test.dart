import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("UserAuth", () {
    test("fromJson() and toJson()", () {
      final json = {
        "token": "test_token",
        "user": {
          "id": "test_id",
          "created": "test_created",
          "updated": "test_updated",
          "verified": true,
          "email": "test_email",
          "lastResetSentAt": "test_lastResetSentAt",
          "lastVerificationSentAt": "test_lastVerificationSentAt",
          "profile": null,
        },
        "meta": {"test": 123},
      };

      final model = UserAuth.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
