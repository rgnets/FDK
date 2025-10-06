import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

abstract class ScannerRepository {
  /// Start a new scanning session
  Future<Either<Failure, ScanSession>> startSession(DeviceType deviceType);
  
  /// Get current scanning session
  Future<Either<Failure, ScanSession?>> getCurrentSession();
  
  /// Update scanning session with new barcode
  Future<Either<Failure, ScanSession>> updateSession(
    String sessionId,
    String barcode,
  );
  
  /// Complete a scanning session and register device
  Future<Either<Failure, void>> completeSession(
    String sessionId,
    Map<String, dynamic> deviceData,
  );
  
  /// Cancel current scanning session
  Future<Either<Failure, void>> cancelSession(String sessionId);
  
  /// Get scanning history
  Future<Either<Failure, List<ScanSession>>> getScanHistory();
  
  /// Clear scan history
  Future<Either<Failure, void>> clearHistory();
  
  /// Validate if barcode is valid for device type
  Future<Either<Failure, bool>> validateBarcode(
    String barcode,
    DeviceType deviceType,
  );
}