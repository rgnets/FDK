import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/providers/app_bar_provider.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/widgets/connection_details_dialog.dart';
import 'package:rgnets_fdk/core/widgets/wave_line_painter.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';

/// Custom app bar widget for FDK application with wave line design
class FDKAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FDKAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  ConsumerState<FDKAppBar> createState() => _FDKAppBarState();
}

class _FDKAppBarState extends ConsumerState<FDKAppBar> with SingleTickerProviderStateMixin {
  // Cached decoration to avoid recreating on every build
  static const _appBarDecoration = BoxDecoration(
    color: Color(0xFF1A1A1A),
    boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 4, offset: Offset(0, 2))],
  );

  // Cached line color to avoid recreating on every build
  static final _lineColor = Colors.grey.withValues(alpha: 0.25);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  // Pre-allocate a single pulse and list to avoid per-frame churn.
  final PulseInfo _singlePulse = PulseInfo(position: 0, intensity: 0.3);
  late final List<PulseInfo> _singlePulseList = [_singlePulse];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: -0.1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.linear));

    _pulseController.repeat();

    LoggerService.debug(
      'FDKAppBar initialized with traveling pulse',
      tag: 'AppBar',
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    // Get the safe area top padding (status bar height)
    final topPadding = MediaQuery.of(context).padding.top;

    // The Scaffold allocates preferredSize.height + topPadding for this widget.
    // We need to:
    // 1. Fill the entire space with our background color (including behind status bar)
    // 2. Push content below the status bar using padding
    return DecoratedBox(
      decoration: _appBarDecoration,
      child: Padding(
        // Push content below the status bar
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(
          height: 65,
          child: Stack(
            children: [
              // Wave line with traveling morse code pulses
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final animValue = _pulseAnimation.value;

                  _singlePulse.position = animValue;

                  return CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 65),
                    painter: WaveLinePainter(
                      lineColor: _lineColor,
                      baseThickness: 0.15,
                      pulseInfos: _singlePulseList,
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
      ),
    );
  }

  Widget _buildLogo() {
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
            HapticFeedback.lightImpact();
            context.go('/notifications');
          },
          badgeColor: Colors.red,
        ),
        const SizedBox(width: 8),
        // Connection status
        _buildActionButton(
          icon: isConnected ? Icons.check_circle_outline : Icons.error_outline,
          onTap: () {
            HapticFeedback.lightImpact();
            _showConnectionStatus(context, isConnected);
          },
          iconColor: isConnected ? Colors.green : Colors.orange,
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
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 22),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                  child: MediaQuery.withNoTextScaling(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showConnectionStatus(BuildContext context, bool isConnected) {
    ConnectionDetailsDialog.show(context);
  }
}
