import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/widgets/network_overview_section.dart';
import 'package:rgnets_fdk/features/home/presentation/widgets/recent_alerts_section.dart';
import 'package:rgnets_fdk/features/home/presentation/widgets/welcome_card.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/device_notification_provider.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Home dashboard screen - Main entry point for the application
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _logAuthState();
  }
  
  void _logAuthState() {
    final authAsync = ref.read(authProvider);
    
    LoggerService.debug('HomeScreen - Auth state type: ${authAsync.runtimeType}', tag: 'HomeScreen');
    authAsync.when(
      data: (auth) {
        LoggerService.debug('HomeScreen - Auth data received', tag: 'HomeScreen');
        auth.maybeWhen(
          authenticated: (user) {
            LoggerService.debug('HomeScreen - User authenticated: username=${user.username}, apiUrl=${user.apiUrl}', tag: 'HomeScreen');
            return null;
          },
          unauthenticated: () {
            LoggerService.debug('HomeScreen - User is unauthenticated', tag: 'HomeScreen');
            return null;
          },
          authenticating: () {
            LoggerService.debug('HomeScreen - User is authenticating', tag: 'HomeScreen');
            return null;
          },
          orElse: () {
            LoggerService.debug('HomeScreen - Auth state is in orElse branch', tag: 'HomeScreen');
            return null;
          },
        );
        return null;
      },
      loading: () {
        LoggerService.debug('HomeScreen - Auth is loading', tag: 'HomeScreen');
        return null;
      },
      error: (error, stack) {
        LoggerService.error('HomeScreen - Auth error', error: error, tag: 'HomeScreen');
        return null;
      },
    );
  }
  
  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(devicesNotifierProvider.notifier).refresh(),
      ref.read(roomsNotifierProvider.notifier).refresh(),
      ref.read(notificationsDomainNotifierProvider.notifier).refresh(),
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    // Watch providers to trigger rebuilds
    ref
      ..watch(authProvider)
      ..watch(homeScreenStatisticsProvider)
      ..watch(roomsNotifierProvider)
      ..watch(notificationsDomainNotifierProvider)
      ..watch(roomStatisticsProvider)
      ..watch(unreadDeviceNotificationCountProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card with user info
              WelcomeCard(),
              SizedBox(height: 24),
              
              // Network overview with statistics
              NetworkOverviewSection(),
              SizedBox(height: 24),
              
              // Recent alerts/notifications
              RecentAlertsSection(),
            ],
          ),
        ),
      ),
    );
  }
}