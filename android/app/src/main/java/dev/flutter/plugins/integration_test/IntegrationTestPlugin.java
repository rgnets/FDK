package dev.flutter.plugins.integration_test;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Stub IntegrationTestPlugin so release builds compile.
 *
 * The real plugin ships in the Flutter SDK's `integration_test` package and
 * is only on the classpath during test runs (`flutter test integration_test/`
 * or `flutter drive`). When Flutter's plugin registrant generator picks up
 * `integration_test` (declared in pubspec.yaml dev_dependencies) and emits
 * an `add(new dev.flutter.plugins.integration_test.IntegrationTestPlugin())`
 * line in `GeneratedPluginRegistrant.java`, release builds fail to compile
 * because the SDK-side class isn't visible to the app's Android classpath.
 *
 * This stub satisfies the symbol resolution. The registrant wraps the
 * `.add()` call in a try/catch, so this no-op plugin attaching at runtime
 * has zero side effects.
 *
 * Long-term cleanup options:
 *   - Add explicit Gradle config in android/app/build.gradle that pulls
 *     the integration_test plugin's AAR onto the release classpath.
 *   - Or restructure pubspec so the plugin registrar excludes it for
 *     release. Flutter does not currently expose a clean knob for this.
 */
public class IntegrationTestPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
