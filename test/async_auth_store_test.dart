import "dart:async";

import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AsyncAuthStore()", () {
    test("load empty initial", () async {
      var saveCalled = 0;

      final store = AsyncAuthStore(
        save: (String data) async {
          saveCalled++;
        },
      );

      expect(saveCalled, 0);
      expect(store.token, "");
      expect(store.record, null);
    });

    test("load RecordModel initial", () async {
      var saveCalled = 0;

      final store = AsyncAuthStore(
        save: (String data) async {
          saveCalled++;

          expect(data, contains('"token":"123"'));
          expect(data, contains('"id":"456"'));
        },
        initial: '{"token":"123", "model":{"id": "456", "collectionId":""}}',
      );

      expect(saveCalled, 1);
      expect(store.token, "123");
      expect(store.record?.id, "456");
    });

    test("async save()", () async {
      var calls = 0;
      final completer = Completer<String>();

      final store = AsyncAuthStore(
        save: (String data) async {
          calls++;
          if (calls == 2) {
            completer.complete(data);
          }
        },
      );

      // ignore: cascade_invocations
      store
        ..save("123", null)
        ..save("456", null);

      await expectLater(await completer.future, contains('"token":"456"'));
      expect(store.token, "456");
    });

    test("async clear with non explicit clear func", () async {
      final completer = Completer<String>();

      final store = AsyncAuthStore(
        save: (String data) async {
          if (data.contains("test")) {
            return;
          }
          completer.complete(data);
        },
      );

      // ignore: cascade_invocations
      store
        ..save("test", null)
        ..clear();

      await expectLater(await completer.future, contains(""));
      expect(store.token, "");
    });

    test("async clear with explicit clear func", () async {
      var saveCalls = 0;
      var clearCalls = 0;

      final store = AsyncAuthStore(
        save: (String data) async {
          saveCalls++;
        },
        clear: () async {
          clearCalls++;
        },
      );

      // ignore: cascade_invocations
      store
        ..save("test", null)
        ..clear()
        ..clear();

      // ignore: inference_failure_on_instance_creation
      await Future.delayed(const Duration(milliseconds: 1));

      expect(store.token, "");
      expect(saveCalls, 1);
      expect(clearCalls, 2);
    });
  });
}
