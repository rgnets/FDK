import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';

final class ExportSettings extends UseCase<Map<String, dynamic>, NoParams> {

  ExportSettings(this.repository);
  final SettingsRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return repository.exportSettings();
  }
}