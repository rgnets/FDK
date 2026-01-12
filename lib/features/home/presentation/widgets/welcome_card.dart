import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';

/// Welcome card widget displaying user info and connection status
class WelcomeCard extends ConsumerWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/images/ui_elements/hud_box.png'),
          fit: BoxFit.fill,
          opacity: 0.15,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authAsync.when(
                      data: (auth) => auth.maybeWhen(
                        authenticated: (user) => 'Welcome, ${user.username}',
                        orElse: () => 'Welcome, Technician',
                      ),
                      loading: () => 'Loading...',
                      error: (_, __) => 'Welcome, Technician',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authAsync.when(
                      data: (auth) => auth.maybeWhen(
                        authenticated: (user) => 'Connected to: ${user.siteUrl.replaceAll('https://', '')}',
                        orElse: () => 'Connected to: Test System',
                      ),
                      loading: () => 'Connecting...',
                      error: (_, __) => 'Connected to: Test System',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}