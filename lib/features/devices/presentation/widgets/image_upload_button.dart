/// Image upload button widget for device detail screens.
///
/// Provides a reusable button that triggers image upload flow:
/// - Shows dialog for camera/gallery selection
/// - Displays upload progress
/// - Shows success/error messages
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rgnets_fdk/features/devices/presentation/providers/image_upload_provider.dart';

/// A button that triggers image upload for a device
class ImageUploadButton extends ConsumerWidget {
  const ImageUploadButton({
    required this.deviceId,
    required this.deviceType,
    required this.existingImages,
    this.roomId,
    this.onUploadComplete,
    this.icon,
    this.label,
    super.key,
  });

  final String deviceId;
  final String deviceType;
  final List<String> existingImages;
  final String? roomId;
  final VoidCallback? onUploadComplete;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(imageUploadNotifierProvider(deviceId));

    // Show snackbar messages
    ref.listen<ImageUploadViewState>(
      imageUploadNotifierProvider(deviceId),
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

    return ElevatedButton.icon(
      onPressed: uploadState.isLoading
          ? null
          : () => _showImageSourceDialog(context, ref),
      icon: uploadState.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.add_a_photo),
      label: Text(
        uploadState.isLoading
            ? 'Uploading...'
            : (label ?? 'Add Photo'),
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

    if (source == null) return;

    await ref.read(imageUploadNotifierProvider(deviceId).notifier).pickAndUploadImages(
      source: source,
      deviceType: deviceType,
      roomId: roomId,
      existingImages: existingImages,
    );
  }
}

/// A floating action button variant for image upload
class ImageUploadFAB extends ConsumerWidget {
  const ImageUploadFAB({
    required this.deviceId,
    required this.deviceType,
    required this.existingImages,
    this.roomId,
    this.onUploadComplete,
    super.key,
  });

  final String deviceId;
  final String deviceType;
  final List<String> existingImages;
  final String? roomId;
  final VoidCallback? onUploadComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(imageUploadNotifierProvider(deviceId));

    // Show snackbar messages
    ref.listen<ImageUploadViewState>(
      imageUploadNotifierProvider(deviceId),
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

    return FloatingActionButton(
      onPressed: uploadState.isLoading
          ? null
          : () => _showImageSourceDialog(context, ref),
      child: uploadState.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.add_a_photo),
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

    if (source == null) return;

    await ref.read(imageUploadNotifierProvider(deviceId).notifier).pickAndUploadImages(
      source: source,
      deviceType: deviceType,
      roomId: roomId,
      existingImages: existingImages,
    );
  }
}

/// An icon button variant for image upload (for toolbars/app bars)
class ImageUploadIconButton extends ConsumerWidget {
  const ImageUploadIconButton({
    required this.deviceId,
    required this.deviceType,
    required this.existingImages,
    this.roomId,
    this.onUploadComplete,
    super.key,
  });

  final String deviceId;
  final String deviceType;
  final List<String> existingImages;
  final String? roomId;
  final VoidCallback? onUploadComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(imageUploadNotifierProvider(deviceId));

    // Show snackbar messages
    ref.listen<ImageUploadViewState>(
      imageUploadNotifierProvider(deviceId),
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

    return IconButton(
      onPressed: uploadState.isLoading
          ? null
          : () => _showImageSourceDialog(context, ref),
      icon: uploadState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add_a_photo),
      tooltip: 'Add photo',
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

    if (source == null) return;

    await ref.read(imageUploadNotifierProvider(deviceId).notifier).pickAndUploadImages(
      source: source,
      deviceType: deviceType,
      roomId: roomId,
      existingImages: existingImages,
    );
  }
}
