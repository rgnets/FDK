import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

final class RebootDevice extends UseCase<void, RebootDeviceParams> {
  RebootDevice(this.repository);

  final DeviceRepository repository;

  @override
  Future<Either<Failure, void>> call(RebootDeviceParams params) async {
    return repository.rebootDevice(params.deviceId);
  }
}

class RebootDeviceParams extends Params {
  const RebootDeviceParams({required this.deviceId});

  final String deviceId;

  @override
  List<Object> get props => [deviceId];
}