class AuthAttempt {
  const AuthAttempt({
    required this.fqdn,
    required this.login,
    required this.success,
    required this.timestamp,
    this.siteName,
    this.message,
  });

  factory AuthAttempt.fromJson(Map<String, dynamic> json) {
    return AuthAttempt(
      fqdn: json['fqdn'] as String? ?? '',
      login: json['login'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      siteName: json['siteName'] as String?,
      message: json['message'] as String?,
    );
  }

  final String fqdn;
  final String login;
  final bool success;
  final DateTime timestamp;
  final String? siteName;
  final String? message;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fqdn': fqdn,
      'login': login,
      'success': success,
      'timestamp': timestamp.toIso8601String(),
      if (siteName != null) 'siteName': siteName,
      if (message != null) 'message': message,
    };
  }

  AuthAttempt copyWith({
    String? fqdn,
    String? login,
    bool? success,
    DateTime? timestamp,
    String? siteName,
    String? message,
  }) {
    return AuthAttempt(
      fqdn: fqdn ?? this.fqdn,
      login: login ?? this.login,
      success: success ?? this.success,
      timestamp: timestamp ?? this.timestamp,
      siteName: siteName ?? this.siteName,
      message: message ?? this.message,
    );
  }
}
