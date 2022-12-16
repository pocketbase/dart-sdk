import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("HealthCheck", () {
    test("fromJson() and toJson()", () {
      final json = {
        "code": 200,
        "message": "test",
      };

      final model = HealthCheck.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
