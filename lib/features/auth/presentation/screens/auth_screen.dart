import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';

/// Authentication screen for QR code scanning
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              
              // QR Scanner button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to scanner and wait for result
                    final result = await context.push<Map<String, dynamic>>('/scanner?mode=auth');
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
  
  Future<void> _processScannedCredentials(Map<String, dynamic> credentials) async {
    if (!mounted) {
      return;
    }
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    
    // Show loading dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: LoadingIndicator(),
      ),
    );
    
    try {
      // Extract credentials from scanned data
      final fqdn = credentials['fqdn'] as String?;
      final login = credentials['login'] as String?;
      final apiKey = credentials['apiKey'] as String?;
      
      if (fqdn == null || login == null || apiKey == null) {
        throw Exception('Invalid QR code format');
      }
      
      // Authenticate with the system
      await ref.read(authProvider.notifier).authenticate(
        fqdn: fqdn,
        login: login,
        apiKey: apiKey,
      );
      
      if (mounted) {
        navigator.pop(); // Close loading dialog
        
        ref.read(authProvider).maybeWhen(
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
                    ),
                  );
                }
              },
              orElse: () {},
            );
          },
          orElse: () {},
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        navigator.pop(); // Close loading dialog
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showManualEntryDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Entry'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'rXg System URL',
                hintText: 'https://your-rxg.com',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Login',
                hintText: 'your-login',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'your-api-key',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}