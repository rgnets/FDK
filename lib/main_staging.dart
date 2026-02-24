import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logging_config.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/onboarding/data/config/onboarding_config.dart';
import 'package:rgnets_fdk/main.dart' show FDKApp;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set environment to staging - uses interurban test API with auto-auth
  EnvironmentConfig.setEnvironment(Environment.staging);
  LoggerService.configure(level: LogLevel.info);
  LoggerService.info('STAGING APP STARTING - main_staging.dart entry point');
  LoggerService.info('SETTING ENVIRONMENT TO STAGING');

  LoggerService.info('INITIALIZING PROVIDERS');
  // Initialize providers
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize onboarding configuration
  try {
    await OnboardingConfig.initialize();
  } on Exception catch (e) {
    LoggerService.warning('Failed to initialize OnboardingConfig: $e');
  }

  LoggerService.info('LAUNCHING APP WITH PROVIDER SCOPE');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FDKApp(),
    ),
  );
}
