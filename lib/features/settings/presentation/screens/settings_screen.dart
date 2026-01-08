import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/widgets/connection_details_dialog.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/features/settings/presentation/providers/settings_riverpod_provider.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppBar removed from SettingsScreen
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final settingsAsync = ref.watch(settingsNotifierProvider);
          final authAsync = ref.watch(authProvider);
          final auth = authAsync.when(
            data: (status) => status,
            loading: () => const AuthStatus.authenticating(),
            error: (_, __) => const AuthStatus.unauthenticated(),
          );

          final cachedSettings = settingsAsync.value;

          return settingsAsync.when(
            data: (settings) => _buildSettingsContent(
              context: context,
              ref: ref,
              settings: settings,
              authStatus: auth,
            ),
            loading: () {
              if (cachedSettings != null) {
                return _buildSettingsContent(
                  context: context,
                  ref: ref,
                  settings: cachedSettings,
                  authStatus: auth,
                  isLoading: true,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text('Failed to load settings'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(settingsNotifierProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent({
    required BuildContext context,
    required WidgetRef ref,
    required SettingsState settings,
    required AuthStatus authStatus,
    bool isLoading = false,
  }) {
    final isAuthenticated = authStatus.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    final authSubtitle = authStatus.maybeWhen(
      authenticated: (user) => user.apiUrl,
      orElse: () => 'Not connected',
    );

    final usernameSubtitle = authStatus.maybeWhen(
      authenticated: (user) => user.username,
      orElse: () => 'Unknown',
    );

    final children = <Widget>[];

    if (isLoading) {
      children.add(const LinearProgressIndicator(minHeight: 4));
    }

    children.addAll([
      _SettingsSection(
        title: 'Connection',
        children: [
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('rXg System'),
            subtitle: Text(authSubtitle),
            trailing: Icon(
              isAuthenticated ? Icons.check_circle : Icons.error,
              color: isAuthenticated ? Colors.green : Colors.red,
            ),
            onTap: () {
              ConnectionDetailsDialog.show(context);
            },
          ),
          if (isAuthenticated)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Username'),
              subtitle: Text(usernameSubtitle),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username cannot be changed while connected'),
                  ),
                );
              },
            ),
        ],
      ),
      _SettingsSection(
        title: 'Application',
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: Text('Current: ${settings.themeMode}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: isLoading
                ? null
                : () {
                    _showThemeDialog(context, ref);
                  },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive alerts and updates'),
            value: settings.enableNotifications,
            onChanged: isLoading
                ? null
                : (value) async {
                    await ref
                        .read(settingsNotifierProvider.notifier)
                        .toggleNotifications();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Notifications enabled'
                                : 'Notifications disabled',
                          ),
                        ),
                      );
                    }
                  },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sync),
            title: const Text('Auto Sync'),
            subtitle: Text(
              'Sync every ${settings.syncInterval == 1 ? "minute" : "${settings.syncInterval} minutes"}',
            ),
            value: settings.autoSync,
            onChanged: isLoading
                ? null
                : (value) async {
                    await ref
                        .read(settingsNotifierProvider.notifier)
                        .toggleAutoSync();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? 'Auto sync enabled' : 'Auto sync disabled',
                          ),
                        ),
                      );
                    }
                  },
          ),
          if (settings.autoSync)
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Sync Interval'),
              subtitle: Text(
                'Every ${settings.syncInterval == 1 ? "minute" : "${settings.syncInterval} minutes"}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: isLoading
                  ? null
                  : () {
                      _showSyncIntervalDialog(context, ref);
                    },
            ),
        ],
      ),
      _SettingsSection(
        title: 'Data Management',
        children: [
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Now'),
            subtitle: const Text('Manually sync with server'),
            onTap: isLoading
                ? null
                : () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing data...')),
                    );

                    // If WebSockets are enabled, trigger a full resync from server
                    if (EnvironmentConfig.useWebSockets) {
                      final syncService =
                          ref.read(webSocketDataSyncServiceProvider);
                      await syncService.syncInitialData();
                    }

                    // Refresh providers to pick up the new data
                    await Future.wait([
                      ref.read(devicesNotifierProvider.notifier).refresh(),
                      ref.read(roomsNotifierProvider.notifier).refresh(),
                      ref
                          .read(notificationsDomainNotifierProvider.notifier)
                          .refresh(),
                    ]);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync complete!')),
                      );
                    }
                  },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove temporary data'),
            onTap: isLoading
                ? null
                : () {
                    _showClearCacheDialog(context, ref);
                  },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download your data as JSON'),
            onTap: isLoading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon'),
                      ),
                    );
                  },
          ),
        ],
      ),
      _SettingsSection(
        title: 'About',
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0 (Build 1)'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help with the app'),
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View privacy information'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy will open in browser'),
                ),
              );
            },
          ),
          if (isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Disconnect from rXg system'),
              onTap: isLoading
                  ? null
                  : () {
                      _showSignOutDialog(context, ref);
                    },
            ),
        ],
      ),
      const SizedBox(height: 32),
    ]);

    return ListView(children: children);
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings are still loading...')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: StatefulBuilder(
          builder: (context, setState) {
            var currentTheme = settings.themeMode;

            Future<void> selectTheme(String theme, String displayName) async {
              setState(() {
                currentTheme = theme;
              });
              await ref
                  .read(settingsNotifierProvider.notifier)
                  .setThemeMode(theme);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Theme updated to $displayName')),
                );
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Dark'),
                  leading: Icon(
                    currentTheme == 'dark'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: currentTheme == 'dark'
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  onTap: () => selectTheme('dark', 'Dark'),
                ),
                ListTile(
                  title: const Text('Light'),
                  leading: Icon(
                    currentTheme == 'light'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: currentTheme == 'light'
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  onTap: () => selectTheme('light', 'Light'),
                ),
                ListTile(
                  title: const Text('System'),
                  leading: Icon(
                    currentTheme == 'system'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: currentTheme == 'system'
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  onTap: () => selectTheme('system', 'System'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSyncIntervalDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings are still loading...')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Interval'),
        content: StatefulBuilder(
          builder: (context, setState) {
            var currentInterval = settings.syncInterval;

            Future<void> selectInterval(int minutes) async {
              setState(() {
                currentInterval = minutes;
              });
              await ref
                  .read(settingsNotifierProvider.notifier)
                  .setSyncInterval(minutes);
              if (context.mounted) {
                Navigator.of(context).pop();
                final displayText = minutes == 1
                    ? '1 minute'
                    : '$minutes minutes';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sync interval set to $displayText')),
                );
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [1, 3, 5, 10].map((minutes) {
                final displayText = minutes == 1
                    ? '1 minute'
                    : '$minutes minutes';
                return ListTile(
                  title: Text(displayText),
                  leading: Icon(
                    currentInterval == minutes
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: currentInterval == minutes
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  onTap: () => selectInterval(minutes),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all temporary data. The app will need to reload data from the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(settingsNotifierProvider.notifier).clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About RG Nets FDK'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RG Nets Field Deployment Kit'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 1'),
            SizedBox(height: 16),
            Text(
              'A comprehensive tool for managing rXg network systems in the field.',
            ),
            SizedBox(height: 16),
            Text('© 2024 RG Nets'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help?', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Check the documentation'),
            Text('• Contact support@rgnets.com'),
            Text('• Visit support.rgnets.com'),
            SizedBox(height: 16),
            Text('Quick Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Swipe to delete notifications'),
            Text('• Pull down to refresh lists'),
            Text('• Tap devices for details'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    // Capture router before showing dialog to avoid using stale context
    final router = GoRouter.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You will need to scan the QR code again to reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Pop dialog first
              Navigator.of(dialogContext).pop();
              // Navigate immediately using captured router (before provider invalidation)
              router.go('/auth');
              // Then sign out (this can happen in background)
              unawaited(ref.read(authProvider.notifier).signOut());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
