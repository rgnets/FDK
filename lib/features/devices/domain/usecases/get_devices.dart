import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices_params.dart';

final class GetDevices extends UseCase<List<Device>, GetDevicesParams> {
  GetDevices(this.repository);

  final DeviceRepository repository;
  final _logger = LoggerService.getLogger();

  @override
  Future<Either<Failure, List<Device>>> call(GetDevicesParams params) async {
    _logger.d('GetDevices use case: Calling repository.getDevices() with fields: ${params.fields?.join(',')}');
    final result = await repository.getDevices(fields: params.fields);
    result.fold(
      (failure) => _logger.e('GetDevices use case: Error - ${failure.message}'),
      (devices) => _logger.i('GetDevices use case: Success - ${devices.length} devices'),
    );
    return result;
  }
}