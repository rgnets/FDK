import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';

final class UpdateSettings extends UseCase<AppSettings, UpdateSettingsParams> {

  UpdateSettings(this.repository);
  final SettingsRepository repository;

  @override
  Future<Either<Failure, AppSettings>> call(UpdateSettingsParams params) {
    return repository.updateSettings(params.settings);
  }
}

class UpdateSettingsParams {

  const UpdateSettingsParams({required this.settings});
  final AppSettings settings;
}