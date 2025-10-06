import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/scanner/data/datasources/scanner_local_data_source.dart';
import 'package:rgnets_fdk/features/scanner/data/models/scan_session_model.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/barcode_data.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/part_number.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_number.dart';
import 'package:uuid/uuid.dart';

class ScannerRepositoryImpl implements ScannerRepository {

  ScannerRepositoryImpl({
    required this.localDataSource,
    required this.deviceRepository,
  });
  final ScannerLocalDataSource localDataSource;
  final DeviceRepository deviceRepository;
  final _uuid = const Uuid();

  @override
  Future<Either<Failure, ScanSession>> startSession(DeviceType deviceType) async {
    LoggerService.debug('🚀 ScannerRepo: Starting session for ${deviceType.name}', tag: 'ScannerRepo');
    
    try {
      final sessionId = _uuid.v4();
      LoggerService.debug('🏆 ScannerRepo: Generated session ID: $sessionId', tag: 'ScannerRepo');
      
      final session = ScanSession(
        id: sessionId,
        deviceType: deviceType,
        startedAt: DateTime.now(),
        scannedBarcodes: [],
        status: ScanSessionStatus.scanning,
      );
      
      LoggerService.debug('📋 ScannerRepo: Created session object', tag: 'ScannerRepo');

      await localDataSource.cacheScanSession(
        ScanSessionModel.fromDomain(session),
      );
      
      LoggerService.debug('✅ ScannerRepo: Session cached successfully', tag: 'ScannerRepo');

      return Right(session);
    } on Exception catch (e) {
      LoggerService.error('❌ ScannerRepo: Failed to start session', error: e, tag: 'ScannerRepo');
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, ScanSession?>> getCurrentSession() async {
    try {
      final model = await localDataSource.getCachedSession();
      return Right(model?.toDomain());
    } on Exception catch (_) {
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, ScanSession>> updateSession(
    String sessionId,
    String barcode,
  ) async {
    LoggerService.debug('🔄 ScannerRepo: Updating session $sessionId with barcode: $barcode', tag: 'ScannerRepo');
    
    try {
      final currentModel = await localDataSource.getCachedSession();
      if (currentModel == null) {
        LoggerService.warning('⚠️ ScannerRepo: No cached session found', tag: 'ScannerRepo');
        return const Left(NotFoundFailure(message: 'Session not found'));
      }
      
      if (currentModel.id != sessionId) {
        LoggerService.warning('⚠️ ScannerRepo: Session ID mismatch. Expected: $sessionId, Found: ${currentModel.id}', tag: 'ScannerRepo');
        return const Left(NotFoundFailure(message: 'Session not found'));
      }
      
      LoggerService.debug('✅ ScannerRepo: Found matching session', tag: 'ScannerRepo');

      var session = currentModel.toDomain();

      // Check if session has timed out (6 seconds)
      final elapsed = DateTime.now().difference(session.startedAt);
      LoggerService.debug('⏰ ScannerRepo: Session elapsed time: ${elapsed.inSeconds} seconds', tag: 'ScannerRepo');
      
      if (elapsed.inSeconds > 6) {
        LoggerService.debug('⏰ ScannerRepo: Session timed out, moving to history', tag: 'ScannerRepo');
        // Session has timed out, start a new one
        session = session.copyWith(
          status: ScanSessionStatus.timeout,
          completedAt: DateTime.now(),
        );
        await localDataSource.addToHistory(
          ScanSessionModel.fromDomain(session),
        );
        await localDataSource.clearCachedSession();
        return const Left(TimeoutFailure(message: 'Scan session timed out'));
      }

      // Process the barcode
      LoggerService.debug('🔍 ScannerRepo: Processing barcode data', tag: 'ScannerRepo');
      final barcodeData = BarcodeData(
        rawValue: barcode,
        format: 'CODE128', // Default format
        scannedAt: DateTime.now(),
      );

      // Determine barcode type and extract value
      BarcodeType type;
      String? extractedValue;

      if (barcodeData.isMacAddress) {
        LoggerService.debug('📶 ScannerRepo: Detected MAC address', tag: 'ScannerRepo');
        type = BarcodeType.macAddress;
        extractedValue = barcodeData.normalizedMacAddress;
        session = session.copyWith(macAddress: extractedValue);
      } else if (barcodeData.isPartNumber) {
        LoggerService.debug('📦 ScannerRepo: Detected part number', tag: 'ScannerRepo');
        type = BarcodeType.partNumber;
        final partResult = PartNumber.create(barcode);
        extractedValue = partResult.fold(
          (l) => barcode,
          (r) => r.value,
        );
        session = session.copyWith(partNumber: extractedValue);
      } else if (barcodeData.isSerialNumber) {
        LoggerService.debug('💼 ScannerRepo: Detected serial number', tag: 'ScannerRepo');
        type = BarcodeType.serialNumber;
        final serialResult = SerialNumber.create(barcode);
        extractedValue = serialResult.fold(
          (l) => barcode,
          (r) => r.value,
        );
        session = session.copyWith(serialNumber: extractedValue);
      } else {
        LoggerService.debug('❓ ScannerRepo: Unknown barcode type', tag: 'ScannerRepo');
        type = BarcodeType.unknown;
        extractedValue = barcode;
      }
      
      LoggerService.debug('🏷️ ScannerRepo: Barcode type: $type, extracted value: $extractedValue', tag: 'ScannerRepo');

      // Add to scanned barcodes
      final scanResult = ScanResult(
        id: _uuid.v4(),
        barcode: barcode,
        type: type,
        value: extractedValue ?? barcode,
        scannedAt: DateTime.now(),
      );

      final updatedBarcodes = [...session.scannedBarcodes, scanResult];
      session = session.copyWith(scannedBarcodes: updatedBarcodes);
      
      LoggerService.debug('📊 ScannerRepo: Session now has ${updatedBarcodes.length} barcodes', tag: 'ScannerRepo');

      // Check if session is complete
      if (session.isComplete) {
        LoggerService.debug('✅ ScannerRepo: Session is now complete!', tag: 'ScannerRepo');
        session = session.copyWith(
          status: ScanSessionStatus.complete,
          completedAt: DateTime.now(),
        );
      } else {
        LoggerService.debug('🔄 ScannerRepo: Session still needs more barcodes', tag: 'ScannerRepo');
      }

      await localDataSource.cacheScanSession(
        ScanSessionModel.fromDomain(session),
      );
      
      LoggerService.debug('✅ ScannerRepo: Session updated and cached', tag: 'ScannerRepo');

      return Right(session);
    } on Exception catch (e) {
      LoggerService.error('❌ ScannerRepo: Failed to update session', error: e, tag: 'ScannerRepo');
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, void>> completeSession(
    String sessionId,
    Map<String, dynamic> deviceData,
  ) async {
    try {
      final currentModel = await localDataSource.getCachedSession();
      if (currentModel == null || currentModel.id != sessionId) {
        return const Left(NotFoundFailure(message: 'Session not found'));
      }

      var session = currentModel.toDomain();
      session = session.copyWith(
        status: ScanSessionStatus.complete,
        completedAt: DateTime.now(),
      );

      // Add to history
      await localDataSource.addToHistory(
        ScanSessionModel.fromDomain(session),
      );

      // Clear current session
      await localDataSource.clearCachedSession();

      // Device registration would be implemented here in production

      return const Right(null);
    } on Exception catch (_) {
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSession(String sessionId) async {
    try {
      final currentModel = await localDataSource.getCachedSession();
      if (currentModel == null || currentModel.id != sessionId) {
        return const Left(NotFoundFailure(message: 'Session not found'));
      }

      var session = currentModel.toDomain();
      session = session.copyWith(
        status: ScanSessionStatus.cancelled,
        completedAt: DateTime.now(),
      );

      // Add to history
      await localDataSource.addToHistory(
        ScanSessionModel.fromDomain(session),
      );

      // Clear current session
      await localDataSource.clearCachedSession();

      return const Right(null);
    } on Exception catch (_) {
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, List<ScanSession>>> getScanHistory() async {
    try {
      final models = await localDataSource.getScanHistory();
      final sessions = models.map((e) => e.toDomain()).toList();
      return Right(sessions);
    } on Exception catch (_) {
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on Exception catch (_) {
      return const Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateBarcode(
    String barcode,
    DeviceType deviceType,
  ) async {
    LoggerService.debug('✅ ScannerRepo: Validating barcode: $barcode for ${deviceType.name}', tag: 'ScannerRepo');
    
    // Basic validation - can be enhanced
    if (barcode.isEmpty || barcode.length < 3) {
      LoggerService.debug('❌ ScannerRepo: Barcode too short or empty', tag: 'ScannerRepo');
      return const Right(false);
    }

    // Check if it matches expected patterns
    final barcodeData = BarcodeData(
      rawValue: barcode,
      format: 'CODE128',
      scannedAt: DateTime.now(),
    );
    
    LoggerService.debug('🔍 ScannerRepo: Checking barcode patterns...', tag: 'ScannerRepo');
    LoggerService.debug('📶 ScannerRepo: Is MAC: ${barcodeData.isMacAddress}', tag: 'ScannerRepo');
    LoggerService.debug('💼 ScannerRepo: Is Serial: ${barcodeData.isSerialNumber}', tag: 'ScannerRepo');
    LoggerService.debug('📦 ScannerRepo: Is Part: ${barcodeData.isPartNumber}', tag: 'ScannerRepo');

    // At least one of these should be true for a valid barcode
    final isValid = barcodeData.isMacAddress ||
        barcodeData.isSerialNumber ||
        barcodeData.isPartNumber;
    
    LoggerService.debug('✅ ScannerRepo: Barcode validation result: $isValid', tag: 'ScannerRepo');

    return Right(isValid);
  }
}