import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final logger = Logger()
    ..i('STAGING APP STARTING - main_staging.dart entry point');
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('SETTING ENVIRONMENT TO STAGING');
  // Set environment to staging - uses interurban test API with auto-auth
  EnvironmentConfig.setEnvironment(Environment.staging);
  
  logger.i('INITIALIZING PROVIDERS');
  // Initialize providers
  final sharedPreferences = await SharedPreferences.getInstance();
  
  logger.i('LAUNCHING APP WITH PROVIDER SCOPE');
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