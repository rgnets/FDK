import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _configureImageCache() {
  const maxBytes = int.fromEnvironment(
    'IMAGE_CACHE_MAX_BYTES',
    defaultValue: 50 * 1024 * 1024,
  );
  const maxCount = int.fromEnvironment(
    'IMAGE_CACHE_MAX_COUNT',
    defaultValue: 200,
  );
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSizeBytes = maxBytes;
  cache.maximumSize = maxCount;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment from dart-define
  const envString = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  // Starting app - environment info available via EnvironmentConfig

  Environment env;
  switch (envString.toLowerCase()) {
    case 'staging':
      env = Environment.staging;
      break;
    case 'production':
      env = Environment.production;
      break;
    case 'development':
    default:
      env = Environment.development;
      break;
  }

  EnvironmentConfig.setEnvironment(env);
  LoggerService.configure();
  _configureImageCache();
  // Environment configuration complete - details available via EnvironmentConfig getters

  // Initialize providers with error handling
  late final SharedPreferences sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } on Exception catch (e) {
    // If SharedPreferences fails, provide a fallback or exit gracefully
    debugPrint('Failed to initialize SharedPreferences: $e');
    return;
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

class FDKApp extends ConsumerStatefulWidget {
  const FDKApp({super.key});

  @override
  ConsumerState<FDKApp> createState() => _FDKAppState();
}

class _FDKAppState extends ConsumerState<FDKApp> {
  @override
  void initState() {
    super.initState();
    // Start background refresh service after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backgroundRefreshServiceProvider).startBackgroundRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RG Nets FDK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
