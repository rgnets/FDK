import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';

HealthNotice notice({
  int id = 1,
  required String name,
  String message = '',
  HealthNoticeSeverity severity = HealthNoticeSeverity.warning,
}) =>
    HealthNotice(
      id: id,
      name: name,
      severity: severity,
      shortMessage: message,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('HealthNotice.isFieldActionable (ATT-FE parity filter)', () {
    test('keeps device-offline notices (rxg monitor_infrastructure_* names)',
        () {
      expect(
        notice(name: 'monitor_infrastructure_access_point_15', message: 'AP OFFLINE: ap1')
            .isFieldActionable,
        isTrue,
      );
      expect(
        notice(name: 'monitor_infrastructure_device_42', message: 'INFRASTRUCTURE DEVICE OFFLINE')
            .isFieldActionable,
        isTrue,
      );
      // Offline detected from the message alone.
      expect(
        notice(name: 'something_else', message: 'Switch is offline').isFieldActionable,
        isTrue,
      );
    });

    test('keeps missing/failed speed-test notices', () {
      expect(notice(name: 'speed_test_failed').isFieldActionable, isTrue);
      expect(
        notice(name: 'x', message: 'Speed test has not been run').isFieldActionable,
        isTrue,
      );
    });

    test('keeps config-sync notices', () {
      expect(notice(name: 'config_sync_error').isFieldActionable, isTrue);
      expect(
        notice(name: 'x', message: 'Configuration Synchronization Failed').isFieldActionable,
        isTrue,
      );
    });

    test('always keeps FDK-synthesized notices (offline synth + compliance)', () {
      // Offline synthesis name prefix.
      expect(
        notice(name: 'fdk_device_offline_ap_7', message: 'AP OFFLINE').isFieldActionable,
        isTrue,
      );
      // Compliance-derived notices use negative ids (missing images, etc.).
      expect(
        notice(id: -10, name: 'compliance_missing_images', message: 'Missing installation images')
            .isFieldActionable,
        isTrue,
      );
    });

    test('drops raw infrastructure / OS plumbing notices ATT-FE never shows', () {
      // The exact example the field engineer flagged.
      expect(
        notice(
          name: 'backend_error',
          message: 'heartbeat timeout of 900s exceeded for /var/run/nokia.sock',
        ).isFieldActionable,
        isFalse,
      );
      for (final n in const [
        'os_kernel',
        'dhcp_warning',
        'deprecation_warning',
        'backend_failure',
        'email_error',
        'portal_warning',
        'mf2_onboarding_infrastructure_device_5', // onboarding (ATT-FE excludes)
        'ping_target_3_monitor',
        'uplink_2_monitor',
        'iot_hub_9',
      ]) {
        expect(notice(name: n, message: 'some diagnostic detail').isFieldActionable, isFalse,
            reason: '$n should be filtered out');
      }
    });
  });
}
