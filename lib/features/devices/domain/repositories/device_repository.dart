import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/control_led.dart';

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

  /// Controls the LED on an access point device
  /// [deviceId] - The ID of the AP device
  /// [action] - The LED action (on, off, blink)
  Future<Either<Failure, void>> controlLed(String deviceId, LedAction action);
}