import 'package:package_info_plus/package_info_plus.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> initializeSentry() async {
    final dsn = EnvironmentConfig.sentryDsn;
    if (dsn.isEmpty) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.environment = EnvironmentConfig.name;
      options.release = '${packageInfo.version}+${packageInfo.buildNumber}';
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0.1;
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;

      options.beforeSend = (event, hint) {
        if (event.throwable?.toString().contains('SocketException') ?? false) {
          return null;
        }
        return event;
      };
    });
  }
}
