import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("CronJob", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "expression": "1 2 3 4 5",
      };

      final model = CronJob.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
