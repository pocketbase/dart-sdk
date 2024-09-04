// ignore_for_file: lines_longer_than_80_chars

import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AuthStore.token and AuthStore.model", () {
    test("read getters", () {
      final store = AuthStore();

      expect(store.token, isEmpty);
      expect(store.record, isNull);

      store.save("test_token", RecordModel({"id": "test"}));

      expect(store.token, "test_token");
      expect(store.record?.id, "test");
    });
  });

  group("AuthStore.isValid", () {
    test("with empty token", () {
      final store = AuthStore();

      expect(store.isValid, isFalse);
    });

    test("with invalid JWT token", () {
      final store = AuthStore()..save("invalid", null);

      expect(store.isValid, isFalse);
    });

    test("with expired JWT token", () {
      const token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDA5OTE2NjF9.TxZjXz_Ks665Hju0FkZSGqHFCYBbgBmMGOLnIzkg9Dg";
      final store = AuthStore()..save(token, null);

      expect(store.isValid, isFalse);
    });

    test("with valid JWT token", () {
      const token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4OTM0NTI0NjF9.yVr-4JxMz6qUf1MIlGx8iW2ktUrQaFecjY_TMm7Bo4o";
      final store = AuthStore()..save(token, null);

      expect(store.isValid, isTrue);
    });
  });

  group("AuthStore.save()", () {
    test("saves new token and model", () async {
      final store = AuthStore();
      const testToken = "test_token";
      final testModel = RecordModel({"id": "test"});

      store.onChange.listen(expectAsync1((e) {
        expect(e.token, testToken);
        expect(e.record, testModel);
      }));

      store.save(testToken, testModel);

      expect(store.token, testToken);
      expect(store.record, testModel);
    });
  });

  group("AuthStore.clear()", () {
    test("clears the stored token and model", () async {
      final store = AuthStore()
        ..save("test_token", RecordModel({"id": "test"}));

      expect(store.token, "test_token");
      expect(store.record?.id, "test");

      store.onChange.listen(expectAsync1((e) {
        expect(e.token, isEmpty);
        expect(e.record, isNull);
      }));

      store.clear();

      expect(store.token, isEmpty);
      expect(store.record, isNull);
    });
  });
}
