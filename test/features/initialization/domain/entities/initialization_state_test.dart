import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';

void main() {
  group('InitializationState', () {
    group('uninitialized', () {
      test('should have isLoading as false', () {
        const state = InitializationState.uninitialized();
        expect(state.isLoading, isFalse);
      });

      test('should have showOverlay as false', () {
        const state = InitializationState.uninitialized();
        expect(state.showOverlay, isFalse);
      });
    });

    group('checkingConnection', () {
      test('should have isLoading as true', () {
        const state = InitializationState.checkingConnection();
        expect(state.isLoading, isTrue);
      });

      test('should have showOverlay as true', () {
        const state = InitializationState.checkingConnection();
        expect(state.showOverlay, isTrue);
      });
    });

    group('validatingCredentials', () {
      test('should have isLoading as true', () {
        const state = InitializationState.validatingCredentials();
        expect(state.isLoading, isTrue);
      });

      test('should have showOverlay as true', () {
        const state = InitializationState.validatingCredentials();
        expect(state.showOverlay, isTrue);
      });
    });

    group('loadingData', () {
      test('should have isLoading as true', () {
        const state = InitializationState.loadingData();
        expect(state.isLoading, isTrue);
      });

      test('should have showOverlay as true', () {
        const state = InitializationState.loadingData();
        expect(state.showOverlay, isTrue);
      });

      test('should have default bytesDownloaded as 0', () {
        const state = InitializationState.loadingData();
        expect(
          state.maybeWhen(
            loadingData: (bytes, _) => bytes,
            orElse: () => -1,
          ),
          equals(0),
        );
      });

      test('should have default currentOperation', () {
        const state = InitializationState.loadingData();
        expect(
          state.maybeWhen(
            loadingData: (_, operation) => operation,
            orElse: () => '',
          ),
          equals('Loading data...'),
        );
      });

      test('should accept custom bytesDownloaded', () {
        const state = InitializationState.loadingData(bytesDownloaded: 1024);
        expect(
          state.maybeWhen(
            loadingData: (bytes, _) => bytes,
            orElse: () => -1,
          ),
          equals(1024),
        );
      });

      test('should accept custom currentOperation', () {
        const state = InitializationState.loadingData(
          currentOperation: 'Loading devices...',
        );
        expect(
          state.maybeWhen(
            loadingData: (_, operation) => operation,
            orElse: () => '',
          ),
          equals('Loading devices...'),
        );
      });
    });

    group('ready', () {
      test('should have isLoading as false', () {
        const state = InitializationState.ready();
        expect(state.isLoading, isFalse);
      });

      test('should have showOverlay as false', () {
        const state = InitializationState.ready();
        expect(state.showOverlay, isFalse);
      });
    });

    group('error', () {
      test('should have isLoading as false', () {
        const state = InitializationState.error(message: 'Connection failed');
        expect(state.isLoading, isFalse);
      });

      test('should have showOverlay as true', () {
        const state = InitializationState.error(message: 'Connection failed');
        expect(state.showOverlay, isTrue);
      });

      test('should store error message', () {
        const state = InitializationState.error(message: 'Connection failed');
        expect(
          state.maybeWhen(
            error: (message, _) => message,
            orElse: () => '',
          ),
          equals('Connection failed'),
        );
      });

      test('should have default retryCount as 0', () {
        const state = InitializationState.error(message: 'Error');
        expect(
          state.maybeWhen(
            error: (_, retryCount) => retryCount,
            orElse: () => -1,
          ),
          equals(0),
        );
      });

      test('should accept custom retryCount', () {
        const state = InitializationState.error(
          message: 'Error',
          retryCount: 2,
        );
        expect(
          state.maybeWhen(
            error: (_, retryCount) => retryCount,
            orElse: () => -1,
          ),
          equals(2),
        );
      });
    });

    group('equality', () {
      test('two uninitialized states should be equal', () {
        const state1 = InitializationState.uninitialized();
        const state2 = InitializationState.uninitialized();
        expect(state1, equals(state2));
      });

      test('two loadingData states with same values should be equal', () {
        const state1 = InitializationState.loadingData(
          bytesDownloaded: 100,
          currentOperation: 'Loading...',
        );
        const state2 = InitializationState.loadingData(
          bytesDownloaded: 100,
          currentOperation: 'Loading...',
        );
        expect(state1, equals(state2));
      });

      test('two error states with same values should be equal', () {
        const state1 = InitializationState.error(
          message: 'Error',
          retryCount: 1,
        );
        const state2 = InitializationState.error(
          message: 'Error',
          retryCount: 1,
        );
        expect(state1, equals(state2));
      });

      test('different states should not be equal', () {
        const state1 = InitializationState.uninitialized();
        const state2 = InitializationState.ready();
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
