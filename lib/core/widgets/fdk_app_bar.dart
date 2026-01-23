import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/providers/app_bar_provider.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/widgets/connection_details_dialog.dart';
import 'package:rgnets_fdk/core/widgets/morse_code_animator.dart';
import 'package:rgnets_fdk/core/widgets/wave_line_painter.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';

/// Represents a morse pulse for traveling animation
class MorsePulse {
  const MorsePulse({required this.startTime, required this.duration, required this.isDash});
  
  final double startTime;
  final double duration;
  final bool isDash; // Track if this is a dash (true) or dot (false)
}

/// Custom app bar widget for FDK application with wave line design
class FDKAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FDKAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  ConsumerState<FDKAppBar> createState() => _FDKAppBarState();
}

class _FDKAppBarState extends ConsumerState<FDKAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late List<MorseSignal> _morsePattern;
  final List<MorsePulse> _activePulses = [];

  @override
  void initState() {
    super.initState();

    // Setup morse code pattern for "control communication cognizance"
    _morsePattern = MorseCodeAnimator.getControlCommunicationCognizancePattern();

    // Pulse animation controller for traveling effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3600), // Slowed down by 20% (was 3000ms, now 3600ms)
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: -0.1, // Start slightly off screen
      end: 1.1, // End slightly off screen
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.linear));

    // Generate morse pulses based on pattern
    _generateMorsePulses();

    // Listen to animation to spawn new pulses
    _pulseAnimation.addListener(_updatePulses);

    // Start the animation
    _pulseController.repeat();

    LoggerService.debug(
      'FDKAppBar initialized with traveling morse code: "control communication cognizance"',
      tag: 'AppBar',
    );
  }

  @override
  void dispose() {
    _pulseAnimation.removeListener(_updatePulses);
    _pulseController.dispose();
    super.dispose();
  }

  void _generateMorsePulses() {
    // Convert morse pattern to pulse spawn times
    double currentTime = 0;
    const unitDuration = 0.05; // Each morse unit is 5% of screen width

    for (final signal in _morsePattern) {
      if (signal.isOn) {
        // Add a pulse for this signal
        // A dash has duration of 3 units, a dot has duration of 1 unit
        final isDash = signal.duration > 2; // If duration > 2, it's a dash
        _activePulses.add(MorsePulse(
          startTime: currentTime, 
          duration: signal.duration * unitDuration,
          isDash: isDash,
        ));
      }
      currentTime += signal.duration * unitDuration;
    }
  }

  void _updatePulses() {
    // Calculate which pulses should be visible based on animation value
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    LoggerService.debug('Building FDKAppBar', tag: 'AppBar');

    final appBarState = ref.watch(appBarProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (error, stack) {
        LoggerService.error('Error getting unread count', error: error, tag: 'AppBar');
        return 0;
      },
    );

    LoggerService.debug(
      'App bar state - Route: ${appBarState.currentRoute}, Title: ${appBarState.pageTitle}',
      tag: 'AppBar',
    );

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Wave line with traveling morse code pulses
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                // Calculate visible pulse positions with intensity
                final visiblePulses = <PulseInfo>[];
                final animValue = _pulseAnimation.value;

                // Each pulse travels across the screen
                for (final pulse in _activePulses) {
                  // Calculate this pulse's position based on its start time and current animation
                  final pulsePos = (animValue - pulse.startTime) % 1.2; // Loop at 1.2 to allow gap

                  // Only show if in valid range
                  if (pulsePos >= -0.1 && pulsePos <= 1.1) {
                    // Add multiple positions for longer signals (dashes)
                    final numPulses = (pulse.duration * 20).round(); // More pulses for longer duration
                    for (var i = 0; i < numPulses; i++) {
                      final offset = i * 0.02; // Small offset between sub-pulses
                      final pos = pulsePos - offset;
                      if (pos >= -0.1 && pos <= 1.1) {
                        visiblePulses.add(PulseInfo(
                          position: pos, 
                          intensity: pulse.isDash ? 0.45 : 0.15, // Dashes are 3x brighter than dots
                        ));
                      }
                    }
                  }
                }

                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 65),
                  painter: WaveLinePainter(
                    lineColor: Colors.grey.withValues(alpha: 0.25),
                    baseThickness: 0.15,  // Extremely thin line (hairline thickness)
                    pulseInfos: visiblePulses,
                    animationValue: animValue,
                  ),
                );
              },
            ),
            // Content on top of the wave line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Left: RG Nets Logo
                  _buildLogo(),

                  // Center: FDK Logo (larger, on top of wave)
                  Expanded(child: _buildCenterSection(appBarState.pageTitle)),

                  // Right: Action buttons
                  _buildActionButtons(context, ref, unreadCount, appBarState.isConnected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    LoggerService.debug('Building logo section', tag: 'AppBar');

    return Container(
      width: 100,
      height: 40,
      padding: const EdgeInsets.only(right: 16),
      child: Image.asset(
        'assets/images/logos/2021_rgnets_logo_twotone_white.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          LoggerService.error('Failed to load RG Nets logo', error: error, tag: 'AppBar');
          return const Icon(Icons.business, color: Colors.white);
        },
      ),
    );
  }

  Widget _buildCenterSection(String subtitle) {
    // Subtitle parameter kept for potential future use or debugging
    LoggerService.debug('Building center section (page: $subtitle)', tag: 'AppBar');

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Image.asset(
          'assets/images/logos/fdk_logo.png',
          height: 40, // Larger logo as per mockup
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.error('Failed to load FDK logo', error: error, tag: 'AppBar');
            return const Text(
              'FDK',
              style: TextStyle(
                fontSize: 24, // Larger text fallback
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, int unreadCount, bool isConnected) {
    return Row(
      children: [
        // Notification button
        _buildActionButton(
          icon: Icons.notifications_outlined,
          badge: unreadCount > 0 ? (unreadCount > 99 ? '99+' : unreadCount.toString()) : null,
          onTap: () {
            LoggerService.debug('Notification button tapped', tag: 'AppBar');
            HapticFeedback.lightImpact();
            context.go('/notifications');
          },
          badgeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
    Color? iconColor,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 22),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: badgeColor ?? Colors.red, borderRadius: BorderRadius.circular(8)),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showConnectionStatus(BuildContext context, bool isConnected) {
    LoggerService.debug('Showing connection status dialog', tag: 'AppBar');
    ConnectionDetailsDialog.show(context);
  }
}
