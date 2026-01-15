import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';

void expectStagingEnvironmentConfig() {
  expect(EnvironmentConfig.isStaging, isTrue);
  expect(EnvironmentConfig.websocketBaseUrl, startsWith('wss://'));
  expect(EnvironmentConfig.apiUsername, isNotEmpty);
  expect(EnvironmentConfig.token, isNotEmpty);
}
