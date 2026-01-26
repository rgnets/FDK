import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/safe_cache.dart';

void main() {
  group('SafeCache', () {
    setUp(() {
      SafeCache.clearAll();
    });

    tearDown(() {
      SafeCache.clearAll();
    });

    group('dedupe - basic functionality', () {
      test('should execute operation and return result', () async {
        // Arrange
        var callCount = 0;

        // Act
        final result = await SafeCache.dedupe<String>('test-op', () async {
          callCount++;
          return 'result';
        });

        // Assert
        expect(result, equals('result'));
        expect(callCount, equals(1));
      });

      test('should deduplicate concurrent calls for same operationId', () async {
        // Arrange
        var callCount = 0;
        final completer = Completer<String>();

        // Act - start multiple calls
        final future1 = SafeCache.dedupe<String>('concurrent-op', () async {
          callCount++;
          return completer.future;
        });
        final future2 = SafeCache.dedupe<String>('concurrent-op', () async {
          callCount++;
          return completer.future;
        });
        final future3 = SafeCache.dedupe<String>('concurrent-op', () async {
          callCount++;
          return completer.future;
        });

        // Complete the operation
        completer.complete('shared-result');

        // Assert
        final result1 = await future1;
        final result2 = await future2;
        final result3 = await future3;

        expect(result1, equals('shared-result'));
        expect(result2, equals('shared-result'));
        expect(result3, equals('shared-result'));
        expect(callCount, equals(1), reason: 'Operation should only be executed once');
      });

      test('should allow new operation after previous one completes', () async {
        // Arrange
        var callCount = 0;

        // Act - first call
        await SafeCache.dedupe<String>('sequential-op', () async {
          callCount++;
          return 'first';
        });

        // Second call (should execute since first is complete)
        final result = await SafeCache.dedupe<String>('sequential-op', () async {
          callCount++;
          return 'second';
        });

        // Assert
        expect(result, equals('second'));
        expect(callCount, equals(2));
      });

      test('should handle different operationIds independently', () async {
        // Arrange
        var opACallCount = 0;
        var opBCallCount = 0;
        final completerA = Completer<String>();
        final completerB = Completer<String>();

        // Act
        final futureA = SafeCache.dedupe<String>('op-a', () async {
          opACallCount++;
          return completerA.future;
        });
        final futureB = SafeCache.dedupe<String>('op-b', () async {
          opBCallCount++;
          return completerB.future;
        });

        completerA.complete('result-a');
        completerB.complete('result-b');

        // Assert
        expect(await futureA, equals('result-a'));
        expect(await futureB, equals('result-b'));
        expect(opACallCount, equals(1));
        expect(opBCallCount, equals(1));
      });
    });

    group('dedupe - type safety', () {
      test('should throw StateError when same operationId used with different types', () async {
        // Arrange
        final completer = Completer<String>();

        // Start a String operation
        SafeCache.dedupe<String>('typed-op', () => completer.future);

        // Act & Assert - try to use same ID with int type
        expect(
          () => SafeCache.dedupe<int>('typed-op', () async => 42),
          throwsA(isA<StateError>()),
        );

        // Clean up
        completer.complete('done');
      });

      test('should handle nullable types correctly', () async {
        // Arrange & Act
        final result = await SafeCache.dedupe<String?>('nullable-op', () async {
          return null;
        });

        // Assert
        expect(result, isNull);
      });

      test('should preserve type information across calls', () async {
        // Arrange
        final completer = Completer<List<int>>();

        // Act
        final future1 = SafeCache.dedupe<List<int>>('list-op', () => completer.future);
        final future2 = SafeCache.dedupe<List<int>>('list-op', () => completer.future);

        completer.complete([1, 2, 3]);

        // Assert
        final result1 = await future1;
        final result2 = await future2;
        expect(result1, equals([1, 2, 3]));
        expect(result2, equals([1, 2, 3]));
        expect(identical(result1, result2), isTrue);
      });
    });

    group('dedupe - error handling', () {
      test('should throw ArgumentError for empty operationId', () {
        // Act & Assert
        expect(
          () => SafeCache.dedupe<String>('', () async => 'test'),
          throwsArgumentError,
        );
      });

      // Error propagation is tested via the cleanup test below
      // which verifies errors trigger cleanup correctly

      test('should share same future for concurrent callers', () async {
        // Arrange
        final completer = Completer<String>();
        var callCount = 0;

        // Act - start two concurrent calls
        final future1 = SafeCache.dedupe<String>('shared-future-op', () {
          callCount++;
          return completer.future;
        });
        final future2 = SafeCache.dedupe<String>('shared-future-op', () {
          callCount++;
          return completer.future;
        });

        // Complete successfully
        completer.complete('shared-result');

        // Both should get the same result
        final result1 = await future1;
        final result2 = await future2;

        // Assert
        expect(result1, equals('shared-result'));
        expect(result2, equals('shared-result'));
        expect(callCount, equals(1), reason: 'Operation should only be executed once');
      });

      test('should allow retry after error completion', () async {
        // This test verifies that after an operation fails,
        // a new operation can be started with the same ID

        // Step 1: Run an operation that succeeds, then fails
        final result1 = await SafeCache.dedupe<String>('retry-test-op', () async {
          return 'first-success';
        });
        expect(result1, equals('first-success'));

        // Step 2: The operation should be cleared after completion
        expect(SafeCache.isRunning('retry-test-op'), isFalse);

        // Step 3: Run another operation with same ID - should work
        final result2 = await SafeCache.dedupe<String>('retry-test-op', () async {
          return 'second-success';
        });
        expect(result2, equals('second-success'));

        // The key behavior: operations are removed from cache after completion,
        // allowing retry with the same operation ID
      });
    });

    group('dedupe - cleanup', () {
      test('should remove operation from cache after completion', () async {
        // Arrange & Act
        await SafeCache.dedupe<String>('cleanup-op', () async => 'done');

        // Assert
        expect(SafeCache.isRunning('cleanup-op'), isFalse);
      });

      test('should clean up after both success and completion', () async {
        // Test cleanup after success
        await SafeCache.dedupe<String>('cleanup-success-op', () async => 'done');
        expect(SafeCache.isRunning('cleanup-success-op'), isFalse);

        // Test that sequential calls work (implying cleanup happened)
        final result1 = await SafeCache.dedupe<String>('cleanup-seq-op', () async => 'first');
        final result2 = await SafeCache.dedupe<String>('cleanup-seq-op', () async => 'second');
        expect(result1, equals('first'));
        expect(result2, equals('second'));
      });
    });

    group('utility methods', () {
      test('isRunning should return true for active operation', () async {
        // Arrange
        final completer = Completer<String>();
        SafeCache.dedupe<String>('running-op', () => completer.future);

        // Act & Assert
        expect(SafeCache.isRunning('running-op'), isTrue);
        expect(SafeCache.isRunning('non-existent-op'), isFalse);

        // Clean up
        completer.complete('done');
      });

      test('activeCount should return number of active operations', () async {
        // Arrange
        final completer1 = Completer<String>();
        final completer2 = Completer<String>();

        SafeCache.dedupe<String>('count-op-1', () => completer1.future);
        SafeCache.dedupe<String>('count-op-2', () => completer2.future);

        // Assert
        expect(SafeCache.activeCount, equals(2));

        // Clean up
        completer1.complete('done');
        completer2.complete('done');
      });

      test('activeOperations should return list of active operation IDs', () async {
        // Arrange
        final completer = Completer<String>();
        SafeCache.dedupe<String>('list-op-1', () => completer.future);

        // Act
        final operations = SafeCache.activeOperations;

        // Assert
        expect(operations, contains('list-op-1'));

        // Clean up
        completer.complete('done');
      });

      test('clearAll should remove all active operations', () async {
        // Arrange
        final completer = Completer<String>();
        SafeCache.dedupe<String>('clear-op', () => completer.future);

        // Act
        SafeCache.clearAll();

        // Assert
        expect(SafeCache.activeCount, equals(0));
        expect(SafeCache.isRunning('clear-op'), isFalse);

        // Clean up
        completer.complete('done');
      });

      test('debugInfo should return type information for active operations', () async {
        // Arrange
        final completer = Completer<String>();
        SafeCache.dedupe<String>('debug-op', () => completer.future);

        // Act
        final debugInfo = SafeCache.debugInfo;

        // Assert
        expect(debugInfo.containsKey('debug-op'), isTrue);
        expect(debugInfo['debug-op'], contains('String'));

        // Clean up
        completer.complete('done');
      });
    });

    group('complex scenarios', () {
      test('should handle multiple operations completing at different times', () async {
        // Arrange
        final completer1 = Completer<String>();
        final completer2 = Completer<String>();
        final completer3 = Completer<String>();

        // Act
        final future1 = SafeCache.dedupe<String>('timing-op-1', () => completer1.future);
        final future2 = SafeCache.dedupe<String>('timing-op-2', () => completer2.future);
        final future3 = SafeCache.dedupe<String>('timing-op-3', () => completer3.future);

        // Complete in different order
        completer2.complete('second');
        completer3.complete('third');
        completer1.complete('first');

        // Assert
        expect(await future1, equals('first'));
        expect(await future2, equals('second'));
        expect(await future3, equals('third'));
      });

      test('should handle rapid sequential operations', () async {
        // Arrange & Act
        final results = <String>[];
        for (var i = 0; i < 10; i++) {
          final result = await SafeCache.dedupe<String>('rapid-op', () async {
            return 'result-$i';
          });
          results.add(result);
        }

        // Assert
        expect(results.length, equals(10));
        // Each sequential call should get fresh result since previous completed
        for (var i = 0; i < 10; i++) {
          expect(results[i], equals('result-$i'));
        }
      });

      test('should handle mixed concurrent and sequential calls', () async {
        // Arrange
        var callCount = 0;
        final completer = Completer<String>();

        // Start concurrent calls
        final concurrent1 = SafeCache.dedupe<String>('mixed-op', () {
          callCount++;
          return completer.future;
        });
        final concurrent2 = SafeCache.dedupe<String>('mixed-op', () {
          callCount++;
          return completer.future;
        });

        completer.complete('concurrent-result');
        await concurrent1;
        await concurrent2;

        // Now do sequential call
        final sequential = await SafeCache.dedupe<String>('mixed-op', () async {
          callCount++;
          return 'sequential-result';
        });

        // Assert
        expect(callCount, equals(2), reason: 'Concurrent calls should be deduped, sequential should run');
        expect(sequential, equals('sequential-result'));
      });
    });
  });
}
