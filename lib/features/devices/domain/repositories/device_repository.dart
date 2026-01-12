import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';

abstract class DeviceRepository {
  Future<Either<Failure, List<Device>>> getDevices({
    List<String>? fields,
  });
  Future<Either<Failure, Device>> getDevice(
    String id, {
    List<String>? fields,
  });
  Future<Either<Failure, List<Device>>> getDevicesByRoom(String roomId);
  Future<Either<Failure, List<Device>>> searchDevices(String query);
  Future<Either<Failure, Device>> updateDevice(Device device);
  Future<Either<Failure, void>> rebootDevice(String deviceId);
  Future<Either<Failure, void>> resetDevice(String deviceId);
  Future<Either<Failure, Device>> deleteDeviceImage(
    String deviceId,
    String imageUrl,
  );
}