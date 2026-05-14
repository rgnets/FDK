/// Centralised log redaction helpers (spec FM-8).
///
/// `api_key=<value>` MUST never reach any log sink, regardless of which
/// service produced the log line. Every layer that logs a URL or a
/// stringified exception passes its payload through these helpers first.
///
/// History: this scrubbing originally lived in `ComplianceRestDataSource`.
/// The multi-LLM review caught four other layers leaking `api_key`:
/// `WebSocketService._open`, `SecureHttpClient.validateConnection`,
/// `_buildActionCableUri` logging in `AuthNotifier`, and Dio-based
/// `RestImageUploadService` exceptions. Lifting the helpers up here makes
/// the FM-8 invariant a single grep target.
///
/// Implementation notes:
/// - URL scrubber is a string-level regex replacement. Rebuilding via
///   `Uri.replace` URL-encodes `[redacted]` brackets and synthesises a
///   trailing `?` when only the api_key was present — both are ugly in
///   logs.
/// - Error scrubber is best-effort: it calls `toString()` then strips
///   `api_key=<value>` substrings. Dio's `toString()` embeds the request
///   URI which is where api_key typically leaks from exceptions.
library;

/// Pre-compiled scrubber. Matches `api_key=…` in both trailing and mid-query
/// positions. `[^&\s"]*` stops at the next param delimiter, whitespace, or
/// a closing quote (Dio's `toString()` embeds the URI in quotes).
final RegExp _apiKeyScrubRegex = RegExp(r'api_key=[^&\s"]*');

const String _redactedReplacement = 'api_key=[redacted]';

/// Strips the `api_key` query parameter from a URI for safe logging.
///
/// Use this for every log line that mentions a URL. Accepts either a `Uri`
/// (typical http/IOClient path) or a raw `String?` (Dio/WebSocket path).
/// Null in → null out so callers can stay terse.
String? scrubUrlForLog(Object? source) {
  if (source == null) {
    return null;
  }
  // Both branches do the same thing — kept distinct for clarity at call
  // sites grep'ing for `Uri` vs `String` inputs.
  final raw = source is Uri ? source.toString() : source.toString();
  return raw.replaceAll(_apiKeyScrubRegex, _redactedReplacement);
}

/// Strips `api_key=<value>` from a stringified error/exception.
///
/// Dio's `DioException.toString()`, the http package's `ClientException`,
/// and `TimeoutException` can all include the full request URI. Pass the
/// raw object — this calls `toString()` internally — so callers don't have
/// to remember to do it themselves.
String scrubErrorForLog(Object? error) {
  if (error == null) {
    return '';
  }
  return error.toString().replaceAll(_apiKeyScrubRegex, _redactedReplacement);
}
