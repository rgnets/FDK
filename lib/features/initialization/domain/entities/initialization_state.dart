import 'package:freezed_annotation/freezed_annotation.dart';

part 'initialization_state.freezed.dart';

/// Represents the initialization state of the application.
///
/// The app goes through several states during startup:
/// - [uninitialized] - Initial state before any initialization begins
/// - [checkingConnection] - Verifying WebSocket connectivity
/// - [validatingCredentials] - Checking auth status
/// - [loadingData] - Loading data via WebSocket with progress tracking
/// - [ready] - Initialization complete, app is ready to use
/// - [error] - Error occurred during initialization
@freezed
class InitializationState with _$InitializationState {
  const factory InitializationState.uninitialized() = _Uninitialized;
  const factory InitializationState.checkingConnection() = _CheckingConnection;
  const factory InitializationState.validatingCredentials() =
      _ValidatingCredentials;
  const factory InitializationState.loadingData({
    @Default(0) int bytesDownloaded,
    @Default('Loading data...') String currentOperation,
  }) = _LoadingData;
  const factory InitializationState.ready() = _Ready;
  const factory InitializationState.error({
    required String message,
    @Default(0) int retryCount,
  }) = _Error;

  const InitializationState._();

  /// Returns true if the app is currently loading data.
  bool get isLoading => maybeWhen(
        checkingConnection: () => true,
        validatingCredentials: () => true,
        loadingData: (_, __) => true,
        orElse: () => false,
      );

  /// Returns true if the overlay should be shown.
  /// Shows for all states except uninitialized and ready.
  bool get showOverlay => maybeWhen(
        uninitialized: () => false,
        ready: () => false,
        orElse: () => true,
      );
}
