import 'dart:async';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/complete_scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/get_current_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_barcode.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/start_scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scanner_notifier.g.dart';

@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  Timer? _sessionTimer;
  static const _sessionTimeout = Duration(seconds: 6);

  ScannerRepository get _scannerRepository =>
      ref.read(scannerRepositoryProvider);

  GetCurrentSession get _getCurrentSession =>
      GetCurrentSession(_scannerRepository);

  StartScanSession get _startScanSession =>
      StartScanSession(_scannerRepository);

  ProcessBarcode get _processBarcode => ProcessBarcode(_scannerRepository);

  CompleteScanSession get _completeScanSession =>
      CompleteScanSession(_scannerRepository);

  @override
  Future<ScannerState> build() async {
    LoggerService.debug('🏁 ScannerNotifier: Building initial state', tag: 'ScannerNotifier');
    
    // Check if there's an existing session
    final getCurrentSession = _getCurrentSession;
    LoggerService.debug('📎 ScannerNotifier: Got getCurrentSession use case', tag: 'ScannerNotifier');
    
    final result = await getCurrentSession(const NoParams());
    LoggerService.debug('📊 ScannerNotifier: GetCurrentSession result received', tag: 'ScannerNotifier');

    return result.fold(
      (failure) {
        LoggerService.debug('⚠️ ScannerNotifier: No existing session or error, starting idle', tag: 'ScannerNotifier');
        return const ScannerState.idle();
      },
      (session) {
        if (session != null) {
          LoggerService.debug('🔄 ScannerNotifier: Found existing session, resuming scanning', tag: 'ScannerNotifier');
          return ScannerState.scanning(session);
        }
        LoggerService.debug('🏁 ScannerNotifier: No existing session, starting idle', tag: 'ScannerNotifier');
        return const ScannerState.idle();
      },
    );
  }

  Future<void> startScanning(DeviceType deviceType) async {
    LoggerService.debug('🚀 ScannerNotifier: Starting scan session for ${deviceType.name}', tag: 'ScannerNotifier');
    state = const AsyncValue.loading();

    final startSession = _startScanSession;
    LoggerService.debug('📎 ScannerNotifier: Got startScanSession use case', tag: 'ScannerNotifier');
    
    final result = await startSession(
      StartScanSessionParams(deviceType: deviceType),
    );
    LoggerService.debug('📊 ScannerNotifier: StartSession result received', tag: 'ScannerNotifier');

    state = result.fold(
      (failure) {
        LoggerService.error('❌ ScannerNotifier: Session start failed', error: failure, tag: 'ScannerNotifier');
        return AsyncValue.error(
          _getFailureMessage(failure),
          StackTrace.current,
        );
      },
      (session) {
        LoggerService.debug('✅ ScannerNotifier: Session started successfully - ID: ${session.id}', tag: 'ScannerNotifier');
        _startSessionTimer();
        return AsyncValue.data(ScannerState.scanning(session));
      },
    );
  }

  Future<void> processBarcode(String barcode) async {
    LoggerService.debug('🔍 ScannerNotifier: Processing barcode: $barcode', tag: 'ScannerNotifier');
    
    final currentState = state.valueOrNull;
    if (currentState == null) {
      LoggerService.warning('⚠️ ScannerNotifier: Current state is null', tag: 'ScannerNotifier');
      return;
    }
    
    if (!currentState.isScanning) {
      LoggerService.warning('⚠️ ScannerNotifier: Not in scanning state: ${currentState.runtimeType}', tag: 'ScannerNotifier');
      return;
    }

    final session = currentState.session;
    if (session == null) {
      LoggerService.warning('⚠️ ScannerNotifier: Session is null', tag: 'ScannerNotifier');
      return;
    }
    
    LoggerService.debug('📋 ScannerNotifier: Session ID: ${session.id}, Device Type: ${session.deviceType.name}', tag: 'ScannerNotifier');

    // Don't process if already complete
    if (session.isComplete) {
      LoggerService.debug('✅ ScannerNotifier: Session already complete, ignoring barcode', tag: 'ScannerNotifier');
      return;
    }

    final processBarcode = _processBarcode;
    LoggerService.debug('📎 ScannerNotifier: Got processBarcode use case', tag: 'ScannerNotifier');
    
    final result = await processBarcode(
      ProcessBarcodeParams(
        sessionId: session.id,
        barcode: barcode,
        deviceType: session.deviceType,
      ),
    );
    LoggerService.debug('📊 ScannerNotifier: ProcessBarcode result received', tag: 'ScannerNotifier');

    result.fold(
      (failure) {
        LoggerService.error('❌ ScannerNotifier: Barcode processing failed', error: failure, tag: 'ScannerNotifier');
        
        if (failure is TimeoutFailure) {
          LoggerService.debug('⏰ ScannerNotifier: Session timed out, resetting to idle', tag: 'ScannerNotifier');
          // Session timed out, reset to idle
          _cancelSessionTimer();
          state = const AsyncValue.data(ScannerState.idle());
        } else {
          LoggerService.debug('⚠️ ScannerNotifier: Setting error state but continuing scanning', tag: 'ScannerNotifier');
          // Show error but continue scanning
          state = AsyncValue.data(
            ScannerState.error(
              _getFailureMessage(failure),
              session,
            ),
          );
        }
      },
      (updatedSession) {
        LoggerService.debug('✅ ScannerNotifier: Barcode processed successfully', tag: 'ScannerNotifier');
        LoggerService.debug('📊 ScannerNotifier: Updated session has ${updatedSession.scannedBarcodes.length} barcodes', tag: 'ScannerNotifier');
        
        // Reset timer on successful scan
        _resetSessionTimer();
        
        if (updatedSession.isComplete) {
          LoggerService.debug('✅ ScannerNotifier: Session is now complete!', tag: 'ScannerNotifier');
          state = AsyncValue.data(
            ScannerState.complete(updatedSession),
          );
        } else {
          LoggerService.debug('🔄 ScannerNotifier: Session updated, still scanning', tag: 'ScannerNotifier');
          state = AsyncValue.data(
            ScannerState.scanning(updatedSession),
          );
        }
      },
    );
  }

  Future<void> completeSession() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.session == null) {
      return;
    }

    final session = currentState.session!;
    if (!session.isComplete) {
      state = AsyncValue.data(
        ScannerState.error(
          'Cannot complete session: missing required fields',
          session,
        ),
      );
      return;
    }

    final completeSession = _completeScanSession;
    final deviceData = {
      'serialNumber': session.serialNumber,
      'macAddress': session.macAddress,
      'partNumber': session.partNumber,
      'assetTag': session.assetTag,
      'deviceType': session.deviceType.name,
    };

    final result = await completeSession(
      CompleteScanSessionParams(
        sessionId: session.id,
        deviceData: deviceData,
      ),
    );

    _cancelSessionTimer();

    state = result.fold(
      (failure) => AsyncValue.data(
        ScannerState.error(
          _getFailureMessage(failure),
          session,
        ),
      ),
      (_) => const AsyncValue.data(ScannerState.success()),
    );
  }

  Future<void> cancelSession() async {
    _cancelSessionTimer();
    state = const AsyncValue.data(ScannerState.idle());
  }

  void _startSessionTimer() {
    _cancelSessionTimer();
    _sessionTimer = Timer(_sessionTimeout, () {
      // Session timeout - reset to idle
      state = const AsyncValue.data(ScannerState.idle());
    });
  }

  void _resetSessionTimer() {
    _startSessionTimer();
  }

  void _cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  String _getFailureMessage(Failure failure) {
    if (failure is TimeoutFailure) {
      return 'Scanning session timed out';
    } else if (failure is NotFoundFailure) {
      return 'Session not found';
    } else if (failure is CacheFailure) {
      return 'Failed to save scan data';
    }
    return 'An error occurred';
  }

  // Clean up timer when provider is disposed
  void cleanup() {
    _cancelSessionTimer();
  }
}

// Scanner state using sealed classes pattern
sealed class ScannerState {
  const ScannerState();

  const factory ScannerState.idle() = IdleState;
  const factory ScannerState.scanning(ScanSession session) = ScanningState;
  const factory ScannerState.complete(ScanSession session) = CompleteState;
  const factory ScannerState.error(String message, ScanSession? session) = ErrorState;
  const factory ScannerState.success() = SuccessState;

  bool get isScanning => this is ScanningState;
  bool get isComplete => this is CompleteState;
  bool get isIdle => this is IdleState;
  
  ScanSession? get session {
    return switch (this) {
      ScanningState(:final session) => session,
      CompleteState(:final session) => session,
      ErrorState(:final session) => session,
      _ => null,
    };
  }
}

class IdleState extends ScannerState {
  const IdleState();
}

class ScanningState extends ScannerState {
  const ScanningState(this.session);
  
  @override
  final ScanSession session;
}

class CompleteState extends ScannerState {
  const CompleteState(this.session);
  
  @override
  final ScanSession session;
}

class ErrorState extends ScannerState {
  const ErrorState(this.message, this.session);
  
  final String message;
  @override
  final ScanSession? session;
}

class SuccessState extends ScannerState {
  const SuccessState();
}

// ValidationFailure is already defined in core/errors/failures.dart
