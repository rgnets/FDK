import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
import 'package:rgnets_fdk/features/debug/debug_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final logger = Logger()
    ..i('🚀 STAGING DEBUG APP STARTING - main_staging_debug.dart entry point');
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('📊 SETTING ENVIRONMENT TO STAGING');
  // Set environment to staging - uses interurban test API with auto-auth
  EnvironmentConfig.setEnvironment(Environment.staging);
  
  logger.i('🔧 INITIALIZING PROVIDERS');
  // Initialize providers
  final sharedPreferences = await SharedPreferences.getInstance();
  
  logger.i('🏗️ LAUNCHING DEBUG APP');
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