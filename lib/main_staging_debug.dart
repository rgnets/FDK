import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logging_config.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
import 'package:rgnets_fdk/features/debug/debug_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set environment to staging - uses interurban test API with auto-auth
  EnvironmentConfig.setEnvironment(Environment.staging);
  LoggerService.configure(level: LogLevel.debug);
  LoggerService.info(
    '🚀 STAGING DEBUG APP STARTING - main_staging_debug.dart entry point',
  );
  LoggerService.info('📊 SETTING ENVIRONMENT TO STAGING');

  LoggerService.info('🔧 INITIALIZING PROVIDERS');
  // Initialize providers
  final sharedPreferences = await SharedPreferences.getInstance();

  LoggerService.info('🏗️ LAUNCHING DEBUG APP');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FDKDebugApp(),
    ),
  );
}

class FDKDebugApp extends StatelessWidget {
  const FDKDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple router that goes directly to debug screen
    final router = GoRouter(
      initialLocation: '/debug',
      routes: [
        GoRoute(
          path: '/debug',
          builder: (context, state) => const DebugScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'RG Nets FDK Debug (Staging)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
