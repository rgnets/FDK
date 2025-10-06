import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';

final class ImportSettings extends UseCase<AppSettings, ImportSettingsParams> {

  ImportSettings(this.repository);
  final SettingsRepository repository;

  @override
  Future<Either<Failure, AppSettings>> call(ImportSettingsParams params) {
    return repository.importSettings(params.data);
  }
}

class ImportSettingsParams {

  const ImportSettingsParams({required this.data});
  final Map<String, dynamic> data;
}