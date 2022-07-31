import "package:pocketbase/src/sse/sse_message.dart";
import "package:test/test.dart";

void main() {
  group("SseMessage", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "event": "test_event",
        "data": "test_data",
        "retry": 123,
      };

      final model = SseMessage.fromJson(json);

      expect(model.toJson(), json);
    });

    test("jsonData() with serialized data object", () {
      final model = SseMessage(data: '{"a": 123}');
      expect(model.jsonData(), {"a": 123});
    });

    test("jsonData() with serialized data array", () {
      final model = SseMessage(data: "[1, 2, 3]");
      expect(model.jsonData(), {
        "data": [1, 2, 3]
      });
    });

    test("jsonData() with non-json data string", () {
      final model = SseMessage(data: "test");
      expect(model.jsonData(), {"data": "test"});
    });

    test("jsonData() with empty data", () {
      final model = SseMessage();
      expect(model.jsonData(), <String, dynamic>{});
    });
  });
}
