import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.statusCode,
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.statusCode,
  });
}

/// Device-related failures
class DeviceFailure extends Failure {
  const DeviceFailure({
    required super.message,
    super.statusCode,
  });
}

/// Room-related failures
class RoomFailure extends Failure {
  const RoomFailure({
    required super.message,
    super.statusCode,
  });
}

/// Notification-related failures
class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    super.statusCode,
  });
}

/// Settings-related failures
class SettingsFailure extends Failure {
  const SettingsFailure({
    required super.message,
    super.statusCode,
  });
}

/// Scanner-related failures
class ScannerFailure extends Failure {
  const ScannerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.statusCode,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.statusCode,
  });
}