import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/widgets/section_card.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/image_upload_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/copyable_field.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/image_viewer_dialog.dart';

/// Widget for displaying all device fields in organized sections
class DeviceDetailSections extends ConsumerWidget {
  const DeviceDetailSections({
    required this.device,
    this.onImageDeletedBySignedId,
    this.onUploadComplete,
    super.key,
  });

  final Device device;
  /// Callback when an image is deleted, provides the signedId
  final void Function(String signedId)? onImageDeletedBySignedId;
  final VoidCallback? onUploadComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBasicInfoSection(context),
        const SizedBox(height: 16),
        _buildLocationSection(context),
        const SizedBox(height: 16),
        _buildWirelessSection(context),
        const SizedBox(height: 16),
        _buildPerformanceSection(context),
        const SizedBox(height: 16),
        _buildTrafficSection(context),
        const SizedBox(height: 16),
        _buildSystemSection(context),
        const SizedBox(height: 16),
        _buildImagesSection(context, ref),
      ],
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return SectionCard(
      title: 'Device Details',
      icon: Icons.info_outline,
      children: [
        CopyableField(label: 'Name', value: device.name),
        _DetailRow('Type', device.type),
        _DetailRow(
          'Status',
          device.status,
          valueColor: _getStatusColor(device.status),
        ),
        if (device.lastSeen != null)
          _DetailRow('Last Seen', _formatDateTime(device.lastSeen!)),
        // Network Configuration
        if (device.ipAddress != null)
          CopyableField(label: 'IP Address', value: device.ipAddress!),
        if (device.macAddress != null)
          CopyableField(label: 'MAC Address', value: device.macAddress!),
        if (device.vlan != null)
          _DetailRow('VLAN', device.vlan.toString()),
        // System Information
        if (device.model != null)
          CopyableField(label: 'Model', value: device.model!),
        if (device.serialNumber != null)
          CopyableField(label: 'Serial Number', value: device.serialNumber!),
        if (device.firmware != null)
          _DetailRow('Firmware', device.firmware!),
        if (device.restartCount != null)
          _DetailRow('Restart Count', device.restartCount.toString()),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    if (device.pmsRoom == null && device.location == null) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        if (device.pmsRoom != null) ...[
          _DetailRow('Room', device.pmsRoom!.displayName),
          _DetailRow('Room ID', device.pmsRoom!.id.toString()),
          if (device.pmsRoom!.extractedBuilding != null)
            _DetailRow('Building', device.pmsRoom!.extractedBuilding!),
          if (device.pmsRoom!.extractedNumber != null)
            _DetailRow('Room Number', device.pmsRoom!.extractedNumber!),
        ],
        if (device.location != null) _DetailRow('Location', device.location!),
        if (device.pmsRoomId != null)
          _DetailRow('PMS Room ID', device.pmsRoomId.toString()),
      ],
    );
  }

  Widget _buildWirelessSection(BuildContext context) {
    if (device.ssid == null &&
        device.channel == null &&
        device.signalStrength == null) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Wireless Configuration',
      icon: Icons.wifi,
      children: [
        if (device.ssid != null) _DetailRow('SSID', device.ssid!),
        if (device.channel != null)
          _DetailRow('Channel', device.channel.toString()),
        if (device.signalStrength != null)
          _DetailRow('Signal Strength', '${device.signalStrength} dBm'),
        if (device.connectedClients != null)
          _DetailRow('Connected Clients', device.connectedClients.toString()),
        if (device.maxClients != null)
          _DetailRow('Max Clients', device.maxClients.toString()),
      ],
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    if (device.cpuUsage == null &&
        device.memoryUsage == null &&
        device.temperature == null &&
        device.uptime == null) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Performance',
      icon: Icons.speed,
      children: [
        if (device.cpuUsage != null)
          _DetailRow('CPU Usage', '${device.cpuUsage}%'),
        if (device.memoryUsage != null)
          _DetailRow('Memory Usage', '${device.memoryUsage}%'),
        if (device.temperature != null)
          _DetailRow('Temperature', '${device.temperature}°C'),
        if (device.uptime != null)
          _DetailRow('Uptime', _formatUptime(device.uptime!)),
        if (device.latency != null)
          _DetailRow('Latency', '${device.latency} ms'),
        if (device.packetLoss != null)
          _DetailRow('Packet Loss', '${device.packetLoss}%'),
      ],
    );
  }

  Widget _buildTrafficSection(BuildContext context) {
    if (device.currentUpload == null &&
        device.currentDownload == null &&
        device.totalUpload == null &&
        device.totalDownload == null) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Traffic Statistics',
      icon: Icons.swap_vert,
      children: [
        if (device.currentUpload != null)
          _DetailRow(
            'Current Upload',
            '${device.currentUpload!.toStringAsFixed(2)} Mbps',
          ),
        if (device.currentDownload != null)
          _DetailRow(
            'Current Download',
            '${device.currentDownload!.toStringAsFixed(2)} Mbps',
          ),
        if (device.totalUpload != null)
          _DetailRow('Total Upload', _formatBytes(device.totalUpload!)),
        if (device.totalDownload != null)
          _DetailRow('Total Download', _formatBytes(device.totalDownload!)),
      ],
    );
  }

  Widget _buildSystemSection(BuildContext context) {
    if (device.model == null &&
        device.serialNumber == null &&
        device.firmware == null &&
        device.restartCount == null) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'System Information',
      icon: Icons.computer,
      children: [
        if (device.model != null)
          CopyableField(label: 'Model', value: device.model!),
        if (device.serialNumber != null)
          CopyableField(label: 'Serial Number', value: device.serialNumber!),
        if (device.firmware != null)
          _DetailRow('Firmware', device.firmware!),
        if (device.restartCount != null)
          _DetailRow('Restart Count', device.restartCount.toString()),
      ],
    );
  }

  /// Filter to only valid HTTP/HTTPS image URLs (for display)
  List<String> get _validImages {
    final images = device.images;
    if (images == null || images.isEmpty) {
      return [];
    }
    return images.where((url) {
      if (url.isEmpty) {
        return false;
      }
      final lower = url.toLowerCase();
      return lower.startsWith('http://') || lower.startsWith('https://');
    }).toList();
  }

  /// Get signed IDs for valid images (for API operations).
  /// The server expects signed IDs for existing images when updating.
  List<String> get _validImageSignedIds {
    final images = device.images;
    final signedIds = device.imageSignedIds;

    if (images == null || images.isEmpty) {
      return [];
    }

    // If we have signed IDs, filter them to match valid images
    if (signedIds != null && signedIds.length == images.length) {
      final result = <String>[];
      for (var i = 0; i < images.length; i++) {
        final url = images[i];
        if (url.isNotEmpty) {
          final lower = url.toLowerCase();
          if (lower.startsWith('http://') || lower.startsWith('https://')) {
            result.add(signedIds[i]);
          }
        }
      }
      return result;
    }

    // Fall back to URLs if signed IDs are not available
    return _validImages;
  }

  Widget _buildImagesSection(BuildContext context, WidgetRef ref) {
    final validImages = _validImages;
    // Authenticate image URLs with api_key for RXG backend access
    final authenticateUrls = ref.watch(authenticatedImageUrlsProvider);
    final authenticatedImages = authenticateUrls(validImages);
    final uploadState = ref.watch(imageUploadNotifierProvider(device.id));

    // Listen for upload state changes to show snackbars and refresh
    ref.listen<ImageUploadViewState>(
      imageUploadNotifierProvider(device.id),
      (previous, next) {
        if (next.successMessage != null && previous?.successMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          onUploadComplete?.call();
        }
        if (next.errorMessage != null && previous?.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return SectionCard(
      title: validImages.isEmpty ? 'Images' : 'Images (${validImages.length})',
      icon: Icons.photo_library,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: authenticatedImages.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              // Last item is the add button
              if (index == authenticatedImages.length) {
                return _buildAddImageButton(context, ref, uploadState);
              }

              final imageUrl = authenticatedImages[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _showImageViewer(
                    context,
                    ref,
                    authenticatedImages,
                    index,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        memCacheHeight: 240,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(
    BuildContext context,
    WidgetRef ref,
    ImageUploadViewState uploadState,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isLoading = uploadState.isLoading;

    return GestureDetector(
      onTap: isLoading ? null : () => _showImageSourceDialog(context, ref),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLoading ? Colors.grey[300]! : primaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: primaryColor,
                ),
              )
            else
              Icon(
                Icons.add_photo_alternate,
                size: 36,
                color: primaryColor,
              ),
            const SizedBox(height: 4),
            Text(
              isLoading ? 'Uploading...' : 'Add Photo',
              style: TextStyle(
                color: isLoading ? Colors.grey[500] : primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              subtitle: const Text('Take a new photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              subtitle: const Text('Choose existing photos'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    await ref.read(imageUploadNotifierProvider(device.id).notifier).pickAndUploadImages(
      source: source,
      deviceType: device.type,  // Pass entity type, not API resource type
      roomId: device.pmsRoomId?.toString(),
      // Use signed IDs for existing images - server expects signed IDs, not URLs
      existingImages: _validImageSignedIds,
    );
  }


  void _showImageViewer(
    BuildContext context,
    WidgetRef ref,
    List<String> images,
    int initialIndex,
  ) {
    // Get api_key for passing to the dialog (images are already authenticated,
    // but we pass api_key for any additional operations the dialog may need)
    final apiKey = ref.read(apiKeyProvider).valueOrNull;
    final signedIds = _validImageSignedIds;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => ImageViewerDialog(
        images: images,
        initialIndex: initialIndex,
        // Pass the index and look up the signedId for deletion
        // This avoids URL mismatch issues since signedIds are stable
        onDeleteAtIndex: onImageDeletedBySignedId != null
            ? (index) {
                if (index >= 0 && index < signedIds.length) {
                  onImageDeletedBySignedId!(signedIds[index]);
                }
              }
            : null,
        apiKey: apiKey,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y h:mm a').format(dateTime);
    }
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
          // Reserve space for alignment with CopyableField
          const SizedBox(width: 26),
        ],
      ),
    );
  }
}
