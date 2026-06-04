import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/login_connection_status.dart';

void main() {
  group('LoginConnectionStatusNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('starts at validatingCredentials with no error', () {
      final status = container.read(loginConnectionStatusProvider);
      expect(status.step, LoginStep.validatingCredentials);
      expect(status.error, isNull);
      expect(status.isFailed, isFalse);
    });

    test('set() advances the step and clears any prior error', () {
      final notifier = container.read(loginConnectionStatusProvider.notifier)
        ..fail('boom')
        ..set(LoginStep.connecting);

      final status = container.read(loginConnectionStatusProvider);
      expect(status.step, LoginStep.connecting);
      expect(status.error, isNull);
      expect(notifier, isNotNull);
    });

    test('fail() marks failed and carries the message', () {
      container
          .read(loginConnectionStatusProvider.notifier)
          .fail('Subscription rejected by server');

      final status = container.read(loginConnectionStatusProvider);
      expect(status.step, LoginStep.failed);
      expect(status.isFailed, isTrue);
      expect(status.error, 'Subscription rejected by server');
    });

    test('reset() returns to the initial stage', () {
      final notifier = container.read(loginConnectionStatusProvider.notifier)
        ..set(LoginStep.connected)
        ..reset();

      final status = container.read(loginConnectionStatusProvider);
      expect(status.step, LoginStep.validatingCredentials);
      expect(status.error, isNull);
      expect(notifier, isNotNull);
    });
  });
}
