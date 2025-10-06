import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';

final class GetCurrentSession extends UseCase<ScanSession?, NoParams> {

  GetCurrentSession(this.repository);
  final ScannerRepository repository;

  @override
  Future<Either<Failure, ScanSession?>> call(NoParams params) {
    return repository.getCurrentSession();
  }
}