// ignore_for_file: lines_longer_than_80_chars

import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AuthStore.token", () {
    test("can be read", () {
      final store = AuthStore();

      expect(store.token, isEmpty);

      store.save("test_token", null);

      expect(store.token, "test_token");
    });
  });

  group("AuthStore.model", () {
    test("can be read", () {
      final store = AuthStore();

      expect(store.model, isNull);

      final record = RecordModel();

      store.save("test_token", record);

      expect(store.model, record);
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
      final testModel = RecordModel();

      store.onChange.listen(expectAsync1((e) {
        expect(e.token, testToken);
        expect(e.model, testModel);
      }));

      store.save(testToken, testModel);

      expect(store.token, testToken);
      expect(store.model, testModel);
    });
  });

  group("AuthStore.clear()", () {
    test("clears the stored token and model", () async {
      final store = AuthStore();
      final testModel = RecordModel();

      store.save("test_token", testModel);

      expect(store.token, "test_token");
      expect(store.model, testModel);

      store.onChange.listen(expectAsync1((e) {
        expect(e.token, isEmpty);
        expect(e.model, isNull);
      }));

      store.clear();

      expect(store.token, isEmpty);
      expect(store.model, isNull);
    });
  });
}
