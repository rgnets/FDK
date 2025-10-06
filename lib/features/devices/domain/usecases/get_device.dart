import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

final class GetDevice extends UseCase<Device, GetDeviceParams> {
  GetDevice(this.repository);

  final DeviceRepository repository;

  @override
  Future<Either<Failure, Device>> call(GetDeviceParams params) async {
    return repository.getDevice(params.id, fields: params.fields);
  }
}

class GetDeviceParams extends Params {
  const GetDeviceParams({
    required this.id,
    this.fields,
  });

  final String id;
  final List<String>? fields;

  @override
  List<Object?> get props => [id, fields];
}