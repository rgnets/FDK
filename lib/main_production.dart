import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/onboarding/data/config/onboarding_config.dart';
import 'package:rgnets_fdk/main.dart' show FDKApp;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment to production
  EnvironmentConfig.setEnvironment(Environment.production);
  LoggerService.configure();

  // Initialize providers with error handling
  late final SharedPreferences sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } on Exception catch (e) {
    debugPrint('Failed to initialize SharedPreferences: $e');
    return;
  }

  // Initialize onboarding configuration
  try {
    await OnboardingConfig.initialize();
  } on Exception catch (e) {
    debugPrint('Failed to initialize OnboardingConfig: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FDKApp(),
    ),
  );
}
