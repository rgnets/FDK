import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logging_config.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
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

class FDKApp extends StatelessWidget {
  const FDKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RG Nets FDK (Staging)',
      debugShowCheckedModeBanner: false, // No debug banner for staging
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
