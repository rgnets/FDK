import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/hold_to_confirm_button.dart';

/// Full-screen image viewer dialog with zoom and delete functionality
class ImageViewerDialog extends StatefulWidget {
  const ImageViewerDialog({
    required this.images,
    required this.initialIndex,
    this.onDeleteAtIndex,
    this.apiKey,
    super.key,
  });

  final List<String> images;
  final int initialIndex;
  /// Callback when an image is deleted, provides the index of the deleted image
  final void Function(int index)? onDeleteAtIndex;
  /// Optional API key for authenticating image URLs.
  /// If provided, will be appended to image URLs that don't already have it.
  final String? apiKey;

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action cannot be undone.',
            ),
            const SizedBox(height: 24),
            HoldToConfirmButton(
              text: 'Hold to Delete',
              icon: Icons.delete,
              holdDuration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
              textColor: Colors.white,
              height: 48,
              width: double.infinity,
              onConfirmed: () {
                Navigator.of(dialogContext).pop();
                widget.onDeleteAtIndex?.call(_currentIndex);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cacheWidth =
        (media.size.width * media.devicePixelRatio).round().clamp(1, 4096);
    final cacheHeight =
        (media.size.height * media.devicePixelRatio).round().clamp(1, 4096);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Image viewer with swipe navigation
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    memCacheWidth: cacheWidth,
                    memCacheHeight: cacheHeight,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top bar with close and delete buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    // Image counter
                    if (widget.images.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    // Delete button
                    if (widget.onDeleteAtIndex != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: _showDeleteConfirmation,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Page indicators
          if (widget.images.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
