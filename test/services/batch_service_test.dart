// ignore_for_file: lines_longer_than_80_chars

import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("BatchService", () {
    test("send create/update/upsert/delete batch request", () async {
      final batchResult = <BatchResult>[
        BatchResult(status: 200, body: {"test": 123}),
        BatchResult(status: 204),
      ];

      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/batch?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");
        expect(
          request.headers["content-type"],
          contains("multipart/form-data; boundary=dart-http-boundary-"),
        );

        // multipart/form-data body check
        expect(request.body, contains("--dart-http-boundary"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="@jsonPayload"\r\n'),
        );
        expect(
          request.body,
          contains(
            '{"test_body":123,"requests":[{"method":"POST","url":"/api/collections/test/records?create=123","headers":{"test":"create_h"},"body":{"title":"create"}},{"method":"PATCH","url":"/api/collections/test/records/%40test_id1?update=123","headers":{"test":"update_h"},"body":{"title":"update"}},{"method":"PUT","url":"/api/collections/test/records?upsert=123","headers":{"test":"upsert_h"},"body":{"title":"upsert"}},{"method":"DELETE","url":"/api/collections/test/records/%40test_id2?d=123","headers":{},"body":{}}]}\r\n',
          ),
        );
        expect(
          request.body,
          contains(
            'content-disposition: form-data; name="requests.0.file"; filename="f1.txt"\r\n',
          ),
        );
        expect(
          request.body,
          contains(
            'content-disposition: form-data; name="requests.0.file"; filename="f2.txt"\r\n',
          ),
        );
        expect(
          request.body,
          contains(
            'content-disposition: form-data; name="requests.1.file"; filename="f3.txt"\r\n',
          ),
        );
        expect(
          request.body,
          contains(
            'content-disposition: form-data; name="requests.2.file"; filename="f4.txt"\r\n',
          ),
        );

        return http.Response(jsonEncode(batchResult), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final f1 = http.MultipartFile.fromString(
        "file",
        "f1",
        filename: "f1.txt",
      );

      final f2 = http.MultipartFile.fromString(
        "file",
        "f2",
        filename: "f2.txt",
      );

      final f3 = http.MultipartFile.fromString(
        "file",
        "f3",
        filename: "f3.txt",
      );

      final f4 = http.MultipartFile.fromString(
        "file",
        "f4",
        filename: "f4.txt",
      );

      final batch = client.createBatch()
        ..collection("test").create(
          body: {"title": "create"},
          files: [f1, f2],
          query: {"create": 123},
          headers: {"test": "create_h"},
        )
        ..collection("test").update(
          "@test_id1",
          body: {"title": "update"},
          files: [f3],
          query: {"update": 123},
          headers: {"test": "update_h"},
        )
        ..collection("test").upsert(
          body: {"title": "upsert"},
          files: [f4],
          query: {"upsert": 123},
          headers: {"test": "upsert_h"},
        )
        ..collection("test").delete("@test_id2", query: {"d": 123});

      final result = await batch.send(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        headers: {
          "test": "789",
        },
      );

      expect(jsonEncode(result), jsonEncode(batchResult));
    });
  });
}
