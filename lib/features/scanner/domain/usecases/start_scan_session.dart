import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';

final class StartScanSession extends UseCase<ScanSession, StartScanSessionParams> {

  StartScanSession(this.repository);
  final ScannerRepository repository;

  @override
  Future<Either<Failure, ScanSession>> call(StartScanSessionParams params) {
    return repository.startSession(params.deviceType);
  }
}

class StartScanSessionParams extends Equatable {

  const StartScanSessionParams({required this.deviceType});
  final DeviceType deviceType;

  @override
  List<Object?> get props => [deviceType];
}