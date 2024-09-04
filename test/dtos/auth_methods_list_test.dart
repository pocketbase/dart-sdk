import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AuthMethodsList", () {
    test("fromJson() and toJson()", () {
      final json = {
        "mfa": {
          "duration": 10,
          "enabled": false,
        },
        "otp": {
          "duration": 20,
          "enabled": true,
        },
        "password": {
          "enabled": true,
          "identityFields": ["a", "b"],
        },
        "oauth2": {
          "enabled": true,
          "providers": [
            AuthMethodProvider(name: "test1").toJson(),
            AuthMethodProvider(name: "test2").toJson(),
          ],
        },
      };

      final model = AuthMethodsList.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
