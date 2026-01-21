import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/control_led.dart';

/// Widget for controlling AP LED (Blink, On, Off)
class LedControlSection extends ConsumerStatefulWidget {
  const LedControlSection({
    required this.deviceId,
    super.key,
  });

  final String deviceId;

  @override
  ConsumerState<LedControlSection> createState() => _LedControlSectionState();
}

class _LedControlSectionState extends ConsumerState<LedControlSection> {
  bool _isSendingCommand = false;
  LedAction? _activeAction;

  Future<void> _sendLedCommand(LedAction action) async {
    if (_isSendingCommand) return;

    setState(() {
      _isSendingCommand = true;
      _activeAction = action;
    });

    try {
      final controlLed = ref.read(controlLedProvider);
      final result = await controlLed(ControlLedParams(
        deviceId: widget.deviceId,
        action: action,
      ));

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('LED ${action.value} command sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCommand = false;
          _activeAction = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'LED Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Blink or toggle the AP LED to help locate the device on-site.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _LedControlButton(
                  label: 'Blink',
                  icon: Icons.bolt_outlined,
                  backgroundColor: Theme.of(context).primaryColor,
                  isLoading: _isSendingCommand && _activeAction == LedAction.blink,
                  isDisabled: _isSendingCommand,
                  onPressed: () => _sendLedCommand(LedAction.blink),
                ),
                _LedControlButton(
                  label: 'Lights On',
                  icon: Icons.lightbulb,
                  backgroundColor: Colors.green.shade700,
                  isLoading: _isSendingCommand && _activeAction == LedAction.on,
                  isDisabled: _isSendingCommand,
                  onPressed: () => _sendLedCommand(LedAction.on),
                ),
                _LedControlButton(
                  label: 'Lights Off',
                  icon: Icons.lightbulb_outline,
                  backgroundColor: Colors.grey.shade800,
                  isLoading: _isSendingCommand && _activeAction == LedAction.off,
                  isDisabled: _isSendingCommand,
                  onPressed: () => _sendLedCommand(LedAction.off),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LedControlButton extends StatelessWidget {
  const _LedControlButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
