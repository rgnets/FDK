import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/message_center_service.dart';
import 'package:rgnets_fdk/core/services/startup_error_collector.dart';

void main() {
  setUp(() {
    MessageCenterService.resetForTesting();
    StartupErrorCollector.reset();
  });

  tearDown(() {
    MessageCenterService.resetForTesting();
    StartupErrorCollector.reset();
  });

  group('StartupErrorCollector', () {
    group('addError', () {
      test('should collect errors before flush', () {
        StartupErrorCollector.addError('Error 1', context: 'test');
        StartupErrorCollector.addError('Error 2', context: 'test');

        expect(StartupErrorCollector.errors.length, equals(2));
        expect(StartupErrorCollector.hasErrors, isTrue);
      });

      test('should include context and stack trace', () {
        StartupErrorCollector.addError(
          'Test error',
          context: 'initialization',
          stackTrace: 'at main.dart:10',
        );

        final error = StartupErrorCollector.errors.first;
        expect(error.message, equals('Test error'));
        expect(error.context, equals('initialization'));
        expect(error.stackTrace, equals('at main.dart:10'));
        expect(error.isWarning, isFalse);
      });

      test('should record timestamp', () {
        final before = DateTime.now();
        StartupErrorCollector.addError('Test error');
        final after = DateTime.now();

        final error = StartupErrorCollector.errors.first;
        expect(error.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(error.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('addWarning', () {
      test('should collect warnings', () {
        StartupErrorCollector.addWarning('Warning 1', context: 'test');

        expect(StartupErrorCollector.errors.length, equals(1));
        expect(StartupErrorCollector.hasWarnings, isTrue);
        expect(StartupErrorCollector.hasErrors, isFalse);
        expect(StartupErrorCollector.errors.first.isWarning, isTrue);
      });
    });

    group('errorCount and warningCount', () {
      test('should count errors and warnings separately', () {
        StartupErrorCollector.addError('Error 1');
        StartupErrorCollector.addError('Error 2');
        StartupErrorCollector.addWarning('Warning 1');

        expect(StartupErrorCollector.errorCount, equals(2));
        expect(StartupErrorCollector.warningCount, equals(1));
      });
    });

    group('flushToMessageCenter', () {
      test('should flush all errors to message center', () async {
        final messageCenter = MessageCenterService();
        messageCenter.initialize();

        final messages = <dynamic>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        StartupErrorCollector.addError('Error 1', context: 'init');
        StartupErrorCollector.addWarning('Warning 1', context: 'init');

        await StartupErrorCollector.flushToMessageCenter(
          delayBetween: const Duration(milliseconds: 50),
        );

        // Wait for messages to be processed
        await Future.delayed(const Duration(milliseconds: 500));

        expect(messages.length, equals(2));
        expect(StartupErrorCollector.errors.isEmpty, isTrue);

        await subscription.cancel();
        messageCenter.dispose();
      });

      test('should only flush once', () async {
        final messageCenter = MessageCenterService();
        messageCenter.initialize();

        StartupErrorCollector.addError('Error 1');

        await StartupErrorCollector.flushToMessageCenter(
          delayBetween: const Duration(milliseconds: 10),
        );

        // Add another error after flush
        StartupErrorCollector.addError('Error 2');

        // Try to flush again (should do nothing)
        await StartupErrorCollector.flushToMessageCenter(
          delayBetween: const Duration(milliseconds: 10),
        );

        // Second error should have been sent directly to message center
        // and errors list should be empty
        expect(StartupErrorCollector.errors.isEmpty, isTrue);

        messageCenter.dispose();
      });

      test('should apply staggered delays', () async {
        final messageCenter = MessageCenterService();
        messageCenter.initialize();

        StartupErrorCollector.addError('Error 1');
        StartupErrorCollector.addError('Error 2');
        StartupErrorCollector.addError('Error 3');

        final startTime = DateTime.now();
        await StartupErrorCollector.flushToMessageCenter(
          delayBetween: const Duration(milliseconds: 100),
        );
        final endTime = DateTime.now();

        // Should take at least 200ms (2 delays for 3 messages)
        expect(
          endTime.difference(startTime).inMilliseconds,
          greaterThanOrEqualTo(180),
        );

        messageCenter.dispose();
      });
    });

    group('clear', () {
      test('should clear all collected errors', () {
        StartupErrorCollector.addError('Error 1');
        StartupErrorCollector.addWarning('Warning 1');

        StartupErrorCollector.clear();

        expect(StartupErrorCollector.errors.isEmpty, isTrue);
        expect(StartupErrorCollector.hasErrors, isFalse);
        expect(StartupErrorCollector.hasWarnings, isFalse);
      });
    });

    group('reset', () {
      test('should reset flush state', () async {
        final messageCenter = MessageCenterService();
        messageCenter.initialize();

        StartupErrorCollector.addError('Error 1');
        await StartupErrorCollector.flushToMessageCenter(
          delayBetween: const Duration(milliseconds: 10),
        );

        StartupErrorCollector.reset();

        // Should be able to collect and flush again
        StartupErrorCollector.addError('Error 2');
        expect(StartupErrorCollector.errors.length, equals(1));

        messageCenter.dispose();
      });
    });

    group('after flush', () {
      test('should send errors directly to message center', () async {
        final messageCenter = MessageCenterService();
        messageCenter.initialize();

        final messages = <dynamic>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        // Flush first (with no errors)
        await StartupErrorCollector.flushToMessageCenter();

        // Now add error after flush
        StartupErrorCollector.addError('Post-flush error');

        await Future.delayed(const Duration(milliseconds: 200));

        // Should be sent directly
        expect(messages.length, equals(1));
        expect(StartupErrorCollector.errors.isEmpty, isTrue);

        await subscription.cancel();
        messageCenter.dispose();
      });
    });
  });
}
