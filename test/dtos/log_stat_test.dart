import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("LogStat", () {
    test("fromJson() and toJson()", () {
      final json = {
        "total": 123,
        "date": "test_date",
      };

      final model = LogStat.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
