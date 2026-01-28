import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/utils/loading_dialog_controller.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/auth/presentation/widgets/credential_approval_sheet.dart';

/// Authentication screen for QR code scanning
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  /// Controller for managing loading dialog state safely.
  /// Using an instance variable ensures proper cleanup across retries.
  final _loadingController = LoadingDialogController();

  @override
  void dispose() {
    // Ensure loading dialog is dismissed when screen is disposed
    _loadingController.ensureDismissed(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'FDK',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Title
                Text(
                  'Connect to rXg System',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan QR code to authenticate',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // QR Scanner button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Navigate to auth-scanner (outside shell) and wait for result
                      final result = await context.push<Map<String, dynamic>>(
                        '/auth-scanner?mode=auth',
                      );
                      if (result != null && context.mounted) {
                        // Process scanned credentials
                        await _processScannedCredentials(result);
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 28),
                    label: const Text(
                      'Scan QR Code',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Manual entry option
                TextButton(
                  onPressed: _showManualEntryDialog,
                  child: const Text('Enter credentials manually'),
                ),

                const SizedBox(height: 32),

                // Show environment-specific message
                if (EnvironmentConfig.isDevelopment)
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            '🚀 Development Mode',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This screen should not appear in development mode.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: 'Go to Home',
                            onPressed: () => context.go('/home'),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (EnvironmentConfig.isStaging)
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '🧪 Staging Mode',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Auto-authenticating with Interurban test API...',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 12),
                          LoadingIndicator(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processScannedCredentials(
    Map<String, dynamic> credentials,
  ) async {
    final logger = ref.read(loggerProvider);
    logger.i('AUTH_SCREEN: _processScannedCredentials called');
    logger.d('AUTH_SCREEN: credentials = $credentials');

    if (!mounted) {
      logger.w('AUTH_SCREEN: Widget not mounted, returning early');
      return;
    }

    // Capture context-dependent objects early while context is valid
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);

    try {
      final fqdn = credentials['fqdn'] as String?;
      final login = credentials['login'] as String?;
      final token = credentials['token'] as String?;
      final siteNameRaw =
          credentials['siteName'] as String? ??
          credentials['site_name'] as String?;
      final issuedAtRaw =
          credentials['issuedAt'] as String? ??
          credentials['issued_at'] as String?;
      final signature = credentials['signature'] as String?;
      final issuedAt = issuedAtRaw != null
          ? DateTime.tryParse(issuedAtRaw)
          : null;
      final siteName =
          siteNameRaw != null && siteNameRaw.trim().isNotEmpty
              ? siteNameRaw.trim()
              : null;

      logger.d('AUTH_SCREEN: Parsed - fqdn=$fqdn, login=$login, token=${token != null ? "${token.substring(0, 4)}..." : "null"}');

      if (fqdn == null || login == null || token == null) {
        logger.e('AUTH_SCREEN: Invalid credential payload - missing required fields');
        throw Exception('Invalid credential payload');
      }

      logger.i('AUTH_SCREEN: Showing credential approval sheet...');
      final approved = await _showCredentialApprovalSheet(
        fqdn: fqdn,
        login: login,
        token: token,
        siteName: siteName,
        issuedAt: issuedAt,
        signature: signature,
      );
      logger.i('AUTH_SCREEN: Approval sheet returned: $approved');

      if (!approved) {
        if (!mounted) {
          logger.w('AUTH_SCREEN: Widget not mounted after approval sheet');
          return;
        }
        logger.w('AUTH_SCREEN: Approval was cancelled or returned false');
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Approval cancelled. You can rescan or edit entries.'),
          ),
        );
        return;
      }

      if (!mounted) {
        return;
      }

      // Show loading dialog using the controller (ensures consistent show/dismiss)
      _loadingController.show(context);
      logger.d('AUTH_SCREEN: Loading dialog shown');

      if (!mounted) {
        _loadingController.ensureDismissed(context);
        return;
      }

      await ref
          .read(authProvider.notifier)
          .authenticate(
            fqdn: fqdn,
            login: login,
            token: token,
            siteName: siteName,
            issuedAt: issuedAt,
            signature: signature,
          )
          .timeout(
            const Duration(seconds: 25),
            onTimeout: () {
              throw TimeoutException('Authentication timed out');
            },
          );

      if (!mounted) {
        _loadingController.ensureDismissed(null);
        return;
      }

      // Dismiss loading dialog using the controller
      if (context.mounted) {
        _loadingController.dismiss(context);
      }
      logger.d('AUTH_SCREEN: Loading dialog dismissed');

      ref
          .read(authProvider)
          .maybeWhen(
            data: (status) {
              status.maybeWhen(
                authenticated: (_) {
                  if (mounted) {
                    goRouter.go('/home');
                  }
                },
                failure: (message) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Retry',
                          onPressed: () {
                            _processScannedCredentials(credentials);
                          },
                        ),
                      ),
                    );
                  }
                },
                orElse: () {},
              );
            },
            orElse: () {},
          );
    } on Exception catch (e) {
      // Always ensure loading dialog is dismissed on error
      if (mounted) {
        _loadingController.dismiss(context);
      } else {
        _loadingController.ensureDismissed(null);
      }

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showCredentialApprovalSheet({
    required String fqdn,
    required String login,
    required String token,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    final logger = ref.read(loggerProvider);
    logger.d('AUTH_SCREEN: _showCredentialApprovalSheet called');
    logger.d('AUTH_SCREEN: context.mounted = $mounted');

    if (!mounted) {
      logger.e('AUTH_SCREEN: Cannot show sheet - widget not mounted');
      return false;
    }

    logger.i('AUTH_SCREEN: Calling showModalBottomSheet...');
    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (sheetContext) {
          logger.d('AUTH_SCREEN: BottomSheet builder executing');
          return CredentialApprovalSheet(
            fqdn: fqdn,
            login: login,
            token: token,
            siteName: siteName,
            issuedAt: issuedAt,
            signature: signature,
          );
        },
      );
      logger.i('AUTH_SCREEN: showModalBottomSheet returned: $result');
      return result ?? false;
    } catch (e, stack) {
      logger.e('AUTH_SCREEN: showModalBottomSheet threw error: $e\n$stack');
      return false;
    }
  }

  Future<void> _showManualEntryDialog() async {
    final result = await showModalBottomSheet<Map<String, String>?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ManualCredentialEntrySheet(),
    );

    if (result == null) {
      return;
    }

    await _processScannedCredentials(<String, dynamic>{
      'fqdn': result['fqdn'],
      'login': result['login'],
      'token': result['token'],
      'siteName': result['siteName'],
    });
  }
}
