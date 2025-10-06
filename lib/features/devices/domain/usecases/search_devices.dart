import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

final class SearchDevices extends UseCase<List<Device>, SearchDevicesParams> {
  SearchDevices(this.repository);

  final DeviceRepository repository;

  @override
  Future<Either<Failure, List<Device>>> call(SearchDevicesParams params) async {
    return repository.searchDevices(params.query);
  }
}

class SearchDevicesParams extends Params {
  const SearchDevicesParams({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}