# Image Handling Requirements - RG Nets Field Deployment Kit

**Created**: 2025-08-17
**Purpose**: Complete specification for image upload, processing, and display

## Overview

All device images must be normalized to consistent dimensions and quality before upload to optimize storage, bandwidth, and performance.

## Image Processing Requirements

### Dimensions
- **Maximum**: 2048x2048 pixels
- **Minimum**: 800x800 pixels
- **Aspect Ratio**: Maintained during resize
- **Orientation**: Auto-corrected based on EXIF data

### Quality & Format
- **Upload Format**: JPEG
- **Quality Setting**: 85% (balance between size and quality)
- **Max File Size**: 10MB after processing
- **Accepted Input Formats**: JPEG, PNG, WebP
- **Color Space**: sRGB

### Validation Rules
1. **Size Check**: Reject images smaller than 800x800px
2. **Format Check**: Only accept JPEG, PNG, WebP
3. **Corruption Check**: Verify image can be decoded
4. **Dimension Check**: Auto-resize if larger than 2048x2048px

## Implementation Pattern

### Dependencies
```yaml
dependencies:
  image: ^4.2.0           # Image processing
  image_picker: ^1.1.2    # Already in dependencies
  cached_network_image: ^3.3.0  # Display optimization
```

### Image Processor Service
```dart
class ImageProcessor {
  static const int maxDimension = 2048;
  static const int minDimension = 800;
  static const int jpegQuality = 85;
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  
  static Future<Uint8List?> processImage(File imageFile) async {
    // 1. Decode and validate
    final image = img.decodeImage(await imageFile.readAsBytes());
    
    // 2. Check minimum size
    if (image.width < minDimension || image.height < minDimension) {
      throw ImageTooSmallException();
    }
    
    // 3. Resize if needed
    if (image.width > maxDimension || image.height > maxDimension) {
      image = _resizeImage(image);
    }
    
    // 4. Encode to JPEG
    return img.encodeJpg(image, quality: jpegQuality);
  }
}
```

## API Integration

### Upload Format
```json
{
  "device_id": 123,
  "pictures": [
    "data:image/jpeg;base64,[base64_encoded_image_data]"
  ]
}
```

### Endpoints
- **ONT**: `PUT /api/devices/{id}.json`
- **AP**: `PUT /api/access_points/{id}.json`
- **Switch**: `PUT /api/switch_devices/{id}.json`

### Request Flow
1. User selects image from camera or gallery
2. App validates minimum dimensions (800x800)
3. App resizes if larger than 2048x2048
4. App encodes to JPEG at 85% quality
5. App converts to base64 data URL
6. App sends to appropriate API endpoint
7. App shows success/failure feedback

## UI/UX Specifications

### Image Selection
```dart
ImagePicker.pickImage(
  source: ImageSource.camera,
  maxWidth: null,  // Don't let picker resize
  maxHeight: null, // We'll handle it
  imageQuality: 100, // Get original
)
```

### Preview Dialog
Before upload, show:
- Image preview (200px height)
- Original dimensions
- Will resize indicator (if applicable)
- File size
- Upload/Cancel buttons

### Error Messages
- **Too Small**: "Image must be at least 800x800 pixels. Your image is {width}x{height}."
- **Invalid Format**: "Please select a JPEG, PNG, or WebP image."
- **Too Large**: "Image file size exceeds 10MB after processing."
- **Processing Failed**: "Unable to process image. Please try another."

## Display Optimization

### Caching Strategy
```dart
CachedNetworkImage(
  imageUrl: deviceImageUrl,
  placeholder: (context, url) => Shimmer.loading(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  cacheManager: CustomCacheManager.instance,
  maxWidthDiskCache: 2048,
  maxHeightDiskCache: 2048,
)
```

### Thumbnail Generation
- Display size: 100x100px in lists
- Full size: Available on tap
- Memory optimization: Use `cacheExtent` in ListView

## Performance Considerations

### Processing Performance
- Use isolate for image processing to avoid UI blocking
- Show progress indicator during processing
- Cache processed images locally before upload

### Memory Management
```dart
class ImageCacheManager {
  static void configure() {
    PaintingBinding.instance.imageCache
      ..maximumSize = 100        // Max 100 images
      ..maximumSizeBytes = 50 << 20; // Max 50MB
  }
}
```

### Upload Optimization
- Queue uploads if multiple images
- Retry failed uploads with exponential backoff
- Show upload progress for large images

## Error Handling

### Retry Logic
```dart
class ImageUploadService {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  Future<void> uploadWithRetry(File image) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        await upload(image);
        return;
      } catch (e) {
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(
            retryDelay * attempts, // Exponential backoff
          );
        } else {
          throw ImageUploadException('Failed after $maxRetries attempts');
        }
      }
    }
  }
}
```

## Testing Requirements

### Unit Tests
- Image dimension validation
- Resize calculations
- Format detection
- Base64 encoding

### Integration Tests
- Camera integration
- Gallery picker
- Upload flow
- Error scenarios

### Performance Tests
- Large image processing time (<3 seconds)
- Memory usage during processing (<100MB spike)
- Upload time for 2048x2048 image (<10 seconds on 4G)

## Platform Considerations

### iOS
- Request photo library permissions
- Handle HEIC format conversion
- Respect photo privacy settings

### Android
- Request storage permissions
- Handle various camera app behaviors
- Support Android 6.0+ (API 23+)

### Web
- Use file input for selection
- Canvas API for resizing
- Blob API for processing

## Migration from Current Implementation

### Current Implementation (device_detail_view.dart:328-343)
```dart
// Current: No validation or resizing
final bytes = File(image.path).readAsBytesSync();
final String base64Image = base64Encode(bytes);
List<String> pictureList = ["data:image/png;base64,$base64Image"];
```

### New Implementation
```dart
// New: With validation and resizing
final processedBytes = await ImageProcessor.processImage(File(image.path));
if (processedBytes == null) {
  throw InvalidImageException();
}
final String base64Image = base64Encode(processedBytes);
List<String> pictureList = ["data:image/jpeg;base64,$base64Image"];
```

## Benefits

1. **Consistent Quality**: All images normalized to same standards
2. **Optimized Storage**: ~70% reduction in storage needs
3. **Faster Uploads**: Smaller files upload faster
4. **Better UX**: Clear feedback about image requirements
5. **Reduced Bandwidth**: Lower data usage for field technicians
6. **Improved Performance**: Optimized images load faster

## Summary

Image handling in the new app will:
- Enforce minimum quality (800x800px)
- Normalize maximum size (2048x2048px)
- Optimize format (JPEG at 85% quality)
- Provide clear user feedback
- Handle errors gracefully
- Cache efficiently for offline viewing

This approach ensures consistent, high-quality images while optimizing for mobile network conditions and device storage constraints.