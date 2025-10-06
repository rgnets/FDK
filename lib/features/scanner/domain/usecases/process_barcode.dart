import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';

final class ProcessBarcode extends UseCase<ScanSession, ProcessBarcodeParams> {

  ProcessBarcode(this.repository);
  final ScannerRepository repository;

  @override
  Future<Either<Failure, ScanSession>> call(ProcessBarcodeParams params) async {
    // First validate the barcode
    final validationResult = await repository.validateBarcode(
      params.barcode,
      params.deviceType,
    );

    return validationResult.fold(
      Left.new,
      (isValid) async {
        if (!isValid) {
          return const Left(ValidationFailure(message: 'Invalid barcode for device type'));
        }
        
        // Update the session with the new barcode
        return repository.updateSession(params.sessionId, params.barcode);
      },
    );
  }
}

class ProcessBarcodeParams extends Equatable {

  const ProcessBarcodeParams({
    required this.sessionId,
    required this.barcode,
    required this.deviceType,
  });
  final String sessionId;
  final String barcode;
  final DeviceType deviceType;

  @override
  List<Object?> get props => [sessionId, barcode, deviceType];
}

// ValidationFailure is already defined in core/errors/failures.dart