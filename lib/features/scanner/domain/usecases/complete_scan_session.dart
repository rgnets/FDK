import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';

final class CompleteScanSession extends UseCase<void, CompleteScanSessionParams> {

  CompleteScanSession(this.repository);
  final ScannerRepository repository;

  @override
  Future<Either<Failure, void>> call(CompleteScanSessionParams params) {
    return repository.completeSession(params.sessionId, params.deviceData);
  }
}

class CompleteScanSessionParams extends Equatable {

  const CompleteScanSessionParams({
    required this.sessionId,
    required this.deviceData,
  });
  final String sessionId;
  final Map<String, dynamic> deviceData;

  @override
  List<Object?> get props => [sessionId, deviceData];
}