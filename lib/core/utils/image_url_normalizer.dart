Uri? parseImageBaseUri(String? baseUrl) {
  if (baseUrl == null) {
    return null;
  }
  final trimmed = baseUrl.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme) {
    return parsed;
  }
  final normalized = trimmed.replaceFirst(RegExp('^/+'), '');
  return Uri.tryParse('https://$normalized');
}

List<String>? normalizeImageUrls(
  dynamic imagesValue, {
  String? baseUrl,
}) {
  if (imagesValue == null || imagesValue is! List) {
    return null;
  }

  final baseUri = parseImageBaseUri(baseUrl);
  final normalized = <String>[];

  for (final entry in imagesValue) {
    final raw = _extractImageEntry(entry);
    if (raw == null) {
      continue;
    }
    final url = _normalizeImageUrl(raw, baseUri);
    if (url != null) {
      normalized.add(url);
    }
  }

  return normalized.isEmpty ? null : normalized;
}

String? _extractImageEntry(dynamic entry) {
  if (entry is String) {
    return entry;
  }
  if (entry is Map) {
    final map = Map<String, dynamic>.from(entry);
    final candidateKeys = [
      'url',
      'image',
      'image_url',
      'full_url',
      'path',
      'src',
    ];
    for (final key in candidateKeys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
  }
  return null;
}

String? _normalizeImageUrl(String raw, Uri? baseUri) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return trimmed;
  }
  if (lower.startsWith('data:')) {
    return trimmed;
  }
  if (baseUri == null) {
    return trimmed;
  }
  return baseUri.resolve(trimmed).toString();
}

/// Returns the image URL as-is. Authentication is now handled via
/// HTTP headers (X-API-Key) passed to CachedNetworkImage's httpHeaders
/// parameter, rather than appending api_key to the URL query string.
///
/// The [apiKey] parameter is retained for API compatibility but is no
/// longer used. Use [imageAuthHeadersProvider] to get the auth headers map.
String? authenticateImageUrl(String? imageUrl, String? apiKey) {
  return imageUrl;
}

/// Returns the image URLs as-is. Authentication is now handled via
/// HTTP headers (X-API-Key) rather than URL query parameters.
List<String> authenticateImageUrls(List<String> imageUrls, String? apiKey) {
  return imageUrls;
}

/// Strips the api_key query parameter from a URL.
///
/// This is useful when we need to convert an authenticated URL back to
/// its original form, for example when deleting an image where the backend
/// expects the original URL without authentication parameters.
String? stripApiKeyFromUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return imageUrl;
  }

  final trimmed = imageUrl.trim();
  final lower = trimmed.toLowerCase();

  // Don't modify data URLs or non-HTTP URLs
  if (lower.startsWith('data:') ||
      (!lower.startsWith('http://') && !lower.startsWith('https://'))) {
    return trimmed;
  }

  try {
    final uri = Uri.parse(trimmed);

    // If no api_key parameter, return as-is
    if (!uri.queryParameters.containsKey('api_key')) {
      return trimmed;
    }

    // Remove api_key from query parameters
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.remove('api_key');

    // If no other query params remain, return URL without query string
    if (newParams.isEmpty) {
      // Reconstruct URL without query string by building it manually
      // since Uri.replace doesn't properly remove trailing '?'
      final buffer = StringBuffer()
        ..write(uri.scheme)
        ..write('://')
        ..write(uri.host);
      if (uri.hasPort && uri.port != 80 && uri.port != 443) {
        buffer
          ..write(':')
          ..write(uri.port);
      }
      buffer.write(uri.path);
      if (uri.hasFragment) {
        buffer
          ..write('#')
          ..write(uri.fragment);
      }
      return buffer.toString();
    }

    return uri.replace(queryParameters: newParams).toString();
  } on FormatException {
    return trimmed;
  }
}

/// Result of extracting image data with both URL (for display) and signed ID (for API calls)
class ImageExtraction {
  final List<String> urls;
  final List<String> signedIds;

  const ImageExtraction({
    required this.urls,
    required this.signedIds,
  });
}

/// Extract both URLs and signed IDs from image data.
///
/// The server returns images as objects with both 'url' (for display) and
/// 'signed_id' (for API operations). When updating images, the API expects
/// signed IDs for existing images, not URLs.
ImageExtraction? extractImagesWithSignedIds(
  dynamic imagesValue, {
  String? baseUrl,
}) {
  if (imagesValue == null || imagesValue is! List) {
    return null;
  }

  final baseUri = parseImageBaseUri(baseUrl);
  final urls = <String>[];
  final signedIds = <String>[];

  for (final entry in imagesValue) {
    String? url;
    String? signedId;

    if (entry is String) {
      // Plain string - could be a URL or a signed ID
      url = _normalizeImageUrl(entry, baseUri);
      // If it looks like a signed ID (not a URL or data URL), store it
      if (url != null &&
          !url.toLowerCase().startsWith('http') &&
          !url.toLowerCase().startsWith('data:')) {
        signedId = url;
      }
    } else if (entry is Map) {
      final map = Map<String, dynamic>.from(entry);

      // Extract URL
      final urlKeys = ['url', 'image', 'image_url', 'full_url', 'path', 'src'];
      for (final key in urlKeys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          url = _normalizeImageUrl(value.trim(), baseUri);
          break;
        }
      }

      // Extract signed_id
      final signedIdKeys = ['signed_id', 'signedId', 'signed_blob_id'];
      for (final key in signedIdKeys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          signedId = value.trim();
          break;
        }
      }
    }

    if (url != null) {
      urls.add(url);
      // If we have a signed ID, use it; otherwise, fall back to the URL
      signedIds.add(signedId ?? url);
    }
  }

  if (urls.isEmpty) {
    return null;
  }

  return ImageExtraction(urls: urls, signedIds: signedIds);
}
