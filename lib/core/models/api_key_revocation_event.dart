import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_key_revocation_event.freezed.dart';
part 'api_key_revocation_event.g.dart';

/// Represents an API key revocation event received from the server.
///
/// This event is sent when:
/// - A new API key is generated (revoking the old one)
/// - An API key is explicitly deleted
/// - An API key expires
/// - A security-triggered revocation occurs
@freezed
class ApiKeyRevocationEvent with _$ApiKeyRevocationEvent {
  const factory ApiKeyRevocationEvent({
    /// The reason for revocation (e.g., 'new_key_generated', 'key_deleted', 'key_expired', 'security_revocation')
    required String reason,

    /// User-facing message explaining the revocation
    String? message,

    /// Timestamp when the revocation occurred
    DateTime? timestamp,
  }) = _ApiKeyRevocationEvent;

  factory ApiKeyRevocationEvent.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyRevocationEventFromJson(json);
}
