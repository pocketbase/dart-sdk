// ignore_for_file: lines_longer_than_80_chars

import "dart:async";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("PocketBase request cancellation", () {
    test("should support manual cancellation with CancelToken", () async {
      final client = PocketBase("https://example.com");
      final cancelToken = CancelToken();
      
      client.httpClientFactory = () => MockClient((request) async {
        // Simulate a slow request
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"test": "data"}', 200);
      });

      // Start request and cancel it immediately
      final future = client.send(
        "/api/test",
        cancelToken: cancelToken,
      );
      
      cancelToken.cancel("Manual cancellation");

      expect(
        () async => await future,
        throwsA(
          predicate((e) => 
            e is ClientException && 
            e.isAbort == true &&
            e.originalError is CancellationException
          ),
        ),
      );
    });

    test("should auto-cancel duplicate requests by default", () async {
      final client = PocketBase("https://example.com")
        ..httpClientFactory = () => MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{"test": "data"}', 200);
        });

      // Send multiple requests to the same endpoint
      final future1 = client.send("/api/test");
      final future2 = client.send("/api/test");
      final future3 = client.send("/api/test");

      // First two should be cancelled, last one should succeed
      expect(
        () async => await future1,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
      
      expect(
        () async => await future2,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );

      final result = await future3;
      expect(result, isNotNull);
    });

    test("should not auto-cancel when autoCancellation is disabled", () async {
      final client = PocketBase("https://example.com")
        ..autoCancellation(false);
      var requestCount = 0;
      
      client.httpClientFactory = () => MockClient((request) async {
        requestCount++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return http.Response('{"test": "data"}', 200);
      });

      // Send multiple requests to the same endpoint
      final future1 = client.send("/api/test");
      final future2 = client.send("/api/test");
      final future3 = client.send("/api/test");

      // All should succeed
      final results = await Future.wait([future1, future2, future3]);
      expect(results.length, 3);
      expect(requestCount, 3);
    });

    test("should use custom requestKey for cancellation", () async {
      final client = PocketBase("https://example.com")
        ..httpClientFactory = () => MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{"test": "data"}', 200);
        });

      // Send requests with same custom key
      final future1 = client.send("/api/test1", requestKey: "customKey");
      final future2 = client.send("/api/test2", requestKey: "customKey");
      final future3 = client.send("/api/test3"); // Different endpoint, no custom key

      // First should be cancelled by second
      expect(
        () async => await future1,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );

      // Second and third should succeed
      final results = await Future.wait([future2, future3]);
      expect(results.length, 2);
    });

    test("should disable auto-cancellation with null requestKey", () async {
      final client = PocketBase("https://example.com");
      var requestCount = 0;
      
      client.httpClientFactory = () => MockClient((request) async {
        requestCount++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return http.Response('{"test": "data"}', 200);
      });

      // Send multiple requests with null requestKey
      final future1 = client.send("/api/test", requestKey: null);
      final future2 = client.send("/api/test", requestKey: null);

      // Both should succeed
      final results = await Future.wait([future1, future2]);
      expect(results.length, 2);
      expect(requestCount, 2);
    });

    test("cancelRequest should cancel specific request", () async {
      final client = PocketBase("https://example.com")
        ..httpClientFactory = () => MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return http.Response('{"test": "data"}', 200);
        });

      // Start request with custom key
      final future = client.send("/api/test", requestKey: "cancelMe");
      
      // Cancel it manually
      client.cancelRequest("cancelMe");

      expect(
        () async => await future,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });

    test("cancelAllRequests should cancel all pending requests", () async {
      final client = PocketBase("https://example.com")
        ..httpClientFactory = () => MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return http.Response('{"test": "data"}', 200);
        });

      // Start multiple requests
      final future1 = client.send("/api/test1", requestKey: "key1");
      final future2 = client.send("/api/test2", requestKey: "key2");
      final future3 = client.send("/api/test3", requestKey: "key3");
      
      // Cancel all
      client.cancelAllRequests();

      // All should be cancelled
      expect(
        () async => await future1,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
      
      expect(
        () async => await future2,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
      
      expect(
        () async => await future3,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });

    test("should set autoCancellation correctly", () {
      PocketBase("https://example.com")
        ..autoCancellation(false)
        ..autoCancellation(true);
      // If no exception thrown, test passes
      expect(true, isTrue);
    });

    test("should call cancelRequest without errors", () {
      PocketBase("https://example.com")
        ..cancelRequest("key1")
        ..cancelRequest("key2");
      // If no exception thrown, test passes
      expect(true, isTrue);
    });

    test("should call cancelAllRequests without errors", () {
      PocketBase("https://example.com").cancelAllRequests();
      // If no exception thrown, test passes
      expect(true, isTrue);
    });

    test("should handle cancellation with combined tokens", () async {
      final client = PocketBase("https://example.com");
      final userToken = CancelToken();
      final parentToken = CancelToken();
      final combinedToken = userToken.combine(parentToken);
      
      client.httpClientFactory = () => MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"test": "data"}', 200);
      });

      final future = client.send(
        "/api/test",
        cancelToken: combinedToken,
      );
      
      // Cancel parent token
      parentToken.cancel("Parent cancelled");

      expect(
        () async => await future,
        throwsA(predicate((e) => 
          e is ClientException && 
          e.isAbort == true &&
          e.originalError is CancellationException
        )),
      );
    });
  });

  group("Service method cancellation", () {
    test("getList should support cancellation", () async {
      final client = PocketBase("https://example.com");
      final cancelToken = CancelToken();
      
      client.httpClientFactory = () => MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"items": [], "totalItems": 0, "totalPages": 0, "page": 1, "perPage": 30}', 200);
      });

      final service = client.collection("test");
      final future = service.getList(cancelToken: cancelToken);
      
      cancelToken.cancel();

      expect(
        () async => await future,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });

    test("getOne should support cancellation", () async {
      final client = PocketBase("https://example.com");
      final cancelToken = CancelToken();
      
      client.httpClientFactory = () => MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"id": "test", "created": "2023-01-01T00:00:00Z", "updated": "2023-01-01T00:00:00Z"}', 200);
      });

      final service = client.collection("test");
      final future = service.getOne("test", cancelToken: cancelToken);
      
      cancelToken.cancel();

      expect(
        () async => await future,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });

    test("create should support cancellation", () async {
      final client = PocketBase("https://example.com");
      final cancelToken = CancelToken();
      
      client.httpClientFactory = () => MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"id": "test", "created": "2023-01-01T00:00:00Z", "updated": "2023-01-01T00:00:00Z"}', 200);
      });

      final service = client.collection("test");
      final future = service.create(
        body: {"name": "test"},
        cancelToken: cancelToken,
      );
      
      cancelToken.cancel();

      expect(
        () async => await future,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });

    test("update should support cancellation", () async {
      final client = PocketBase("https://example.com");
      final cancelToken = CancelToken();
      
      client.httpClientFactory = () => MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"id": "test", "created": "2023-01-01T00:00:00Z", "updated": "2023-01-01T00:00:00Z"}', 200);
      });

      final service = client.collection("test");
      final future = service.update(
        "test",
        body: {"name": "updated"},
        cancelToken: cancelToken,
      );
      
      cancelToken.cancel();

      expect(
        () async => await future,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });

    test("delete should support cancellation", () async {
      final client = PocketBase("https://example.com");
      final cancelToken = CancelToken();
      
      client.httpClientFactory = () => MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response("", 204);
      });

      final service = client.collection("test");
      final future = service.delete("test", cancelToken: cancelToken);
      
      cancelToken.cancel();

      expect(
        () async => await future,
        throwsA(predicate((e) => e is ClientException && e.isAbort == true)),
      );
    });
  });
}
