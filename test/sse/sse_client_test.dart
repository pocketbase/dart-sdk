import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/src/sse/sse_client.dart";
import "package:test/test.dart";

void main() {
  group("SseClient", () {
    test("initialize and stream SseMessage objects", () {
      final mock2 = MockClient.streaming(
        (http.BaseRequest request, http.ByteStream bodyStream) async {
          final stream = Stream.fromIterable([
            "id:test_id1\n",
            "event:test_event1\n",
            'data:{"a":123}\n',
            "random line that should be ignored\n",
            "retry:100\n",
            "\n",
            "id:test_id2\n",
            "event:test_event2\n",
            "data:none_object\n",
            "another random line that should be ignored\n",
            "\n",
          ]).transform(utf8.encoder);

          return http.StreamedResponse(stream, 200);
        },
      );

      final client = SseClient("/base", httpClientFactory: () => mock2);
      var count = 0;
      client.onMessage.listen(expectAsync1((a) {
        count++;
        if (count == 1) {
          expect(a.id, "test_id1");
          expect(a.event, "test_event1");
          expect(a.data, '{"a":123}');
          expect(a.retry, 100);
          expect(a.jsonData(), equals({"a": 123}));
        } else if (count == 2) {
          expect(a.id, "test_id2");
          expect(a.event, "test_event2");
          expect(a.data, "none_object");
          expect(a.retry, 0);
          expect(a.jsonData(), equals({"data": "none_object"}));
        }
      }, count: 2));
    });
  });
}
