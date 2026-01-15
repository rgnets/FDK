import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/config/environment.dart';

/// Shared toggle for verbose logging in debug development builds.
bool get isVerboseLoggingEnabled =>
    kDebugMode && EnvironmentConfig.isDevelopment;
