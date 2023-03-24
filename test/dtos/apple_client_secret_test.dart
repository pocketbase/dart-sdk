import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AppleClientSecret", () {
    test("fromJson() and toJson()", () {
      final json = {
        "secret": "test",
      };

      final model = AppleClientSecret.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
