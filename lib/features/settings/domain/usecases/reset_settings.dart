import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';

final class ResetSettings extends UseCase<void, NoParams> {

  ResetSettings(this.repository);
  final SettingsRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.resetSettings();
  }
}