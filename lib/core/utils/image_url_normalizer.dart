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
