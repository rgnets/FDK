import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/widgets/section_card.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_device_view_model.dart';

/// A dropdown of the PMS room's devices; selecting one opens that device's
/// detail screen. Hidden when the room has no devices.
class RoomDeviceDropdown extends ConsumerWidget {
  const RoomDeviceDropdown({required this.roomId, super.key});

  /// The room view-model id (string), as used by [roomDeviceNotifierProvider].
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(roomDeviceNotifierProvider(roomId)).allDevices;
    if (devices.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        title: 'Devices (${devices.length})',
        icon: Icons.devices_other,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<Device>(
              isExpanded: true,
              hint: const Text('Select a device to view'),
              icon: const Icon(Icons.arrow_drop_down),
              borderRadius: BorderRadius.circular(8),
              items: [
                for (final device in devices)
                  DropdownMenuItem<Device>(
                    value: device,
                    child: Row(
                      children: [
                        Icon(
                          _iconFor(device.type),
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            device.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: device.status.toLowerCase() == 'online'
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              // Navigate on select; keep value null so it always shows the hint.
              onChanged: (device) {
                if (device != null) context.push('/devices/${device.id}');
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case DeviceTypes.accessPoint:
        return Icons.wifi;
      case DeviceTypes.ont:
        return Icons.router;
      case DeviceTypes.networkSwitch:
        return Icons.hub;
      case DeviceTypes.wlanController:
        return Icons.settings_input_antenna;
      default:
        return Icons.devices_other;
    }
  }
}
