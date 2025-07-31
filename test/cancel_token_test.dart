// ignore_for_file: lines_longer_than_80_chars

import "dart:async";

import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("CancelToken", () {
    test("should be initially not cancelled", () {
      final token = CancelToken();
      expect(token.isCancelled, isFalse);
      expect(token.reason, isNull);
    });

    test("should be cancelled when cancel() is called", () {
      final token = CancelToken()..cancel("Test reason");
      
      expect(token.isCancelled, isTrue);
      expect(token.reason, "Test reason");
    });

    test("should complete whenCancelled future when cancelled", () async {
      final token = CancelToken();
      var completed = false;

      token.whenCancelled.then((_) => completed = true).ignore();
      
      // Should not be completed yet
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(completed, isFalse);
      
      // Cancel and check completion
      token.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(completed, isTrue);
    });

    test("should not cancel multiple times", () {
      final token = CancelToken()
        ..cancel("First reason")
        ..cancel("Second reason");
      
      expect(token.isCancelled, isTrue);
      expect(token.reason, "First reason");
    });

    test("should use default reason when none provided", () {
      final token = CancelToken()..cancel();
      
      expect(token.reason, "Request was cancelled");
    });

    test("throwIfCancelled should throw when cancelled", () {
      final token = CancelToken()..cancel("Test cancellation");
      
      expect(
        token.throwIfCancelled,
        throwsA(isA<CancellationException>()),
      );
    });

    test("throwIfCancelled should not throw when not cancelled", () {
      final token = CancelToken();
      
      expect(token.throwIfCancelled, returnsNormally);
    });

    test("combine should return cancelled token if first is cancelled", () {
      final token1 = CancelToken()..cancel("Token 1 cancelled");
      final token2 = CancelToken();
      
      final combined = token1.combine(token2);
      
      expect(combined.isCancelled, isTrue);
      expect(combined.reason, "Token 1 cancelled");
    });

    test("combine should return cancelled token if second is cancelled", () {
      final token1 = CancelToken();
      final token2 = CancelToken()..cancel("Token 2 cancelled");
      
      final combined = token1.combine(token2);
      
      expect(combined.isCancelled, isTrue);
      expect(combined.reason, "Token 2 cancelled");
    });

    test("combine should cancel when first token is cancelled later", () async {
      final token1 = CancelToken();
      final token2 = CancelToken();
      final combined = token1.combine(token2);
      
      expect(combined.isCancelled, isFalse);
      
      token1.cancel("Token 1 cancelled later");
      await Future<void>.delayed(const Duration(milliseconds: 10));
      
      expect(combined.isCancelled, isTrue);
      expect(combined.reason, "Token 1 cancelled later");
    });

    test("combine should cancel when second token is cancelled later", () async {
      final token1 = CancelToken();
      final token2 = CancelToken();
      final combined = token1.combine(token2);
      
      expect(combined.isCancelled, isFalse);
      
      token2.cancel("Token 2 cancelled later");
      await Future<void>.delayed(const Duration(milliseconds: 10));
      
      expect(combined.isCancelled, isTrue);
      expect(combined.reason, "Token 2 cancelled later");
    });
  });

  group("CancellationException", () {
    test("should have correct message", () {
      const exception = CancellationException("Test message");
      expect(exception.message, "Test message");
      expect(exception.toString(), "CancellationException: Test message");
    });
  });
}
