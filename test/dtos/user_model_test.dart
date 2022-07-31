import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("UserModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "created": "test_created",
        "updated": "test_updated",
        "verified": true,
        "email": "test_email",
        "lastResetSentAt": "test_lastResetSentAt",
        "lastVerificationSentAt": "test_lastVerificationSentAt",
        "profile": {
          "id": "test_id",
          "created": "test_created",
          "updated": "test_updated",
          "@collectionId": "test_collectionId",
          "@collectionName": "test_collectionName",
          "@expand": {
            "test": {"a": 1}
          },
          "a": 1,
        },
      };

      final model = UserModel.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
