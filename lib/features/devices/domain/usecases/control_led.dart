import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

/// LED control actions available for access points
enum LedAction {
  on,
  off,
  blink,
}

extension LedActionExtension on LedAction {
  String get value {
    switch (this) {
      case LedAction.on:
        return 'on';
      case LedAction.off:
        return 'off';
      case LedAction.blink:
        return 'blink';
    }
  }

  static LedAction? fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'on':
        return LedAction.on;
      case 'off':
        return LedAction.off;
      case 'blink':
        return LedAction.blink;
      default:
        return null;
    }
  }
}

/// Use case for controlling AP LED
final class ControlLed extends UseCase<void, ControlLedParams> {
  ControlLed(this.repository);

  final DeviceRepository repository;

  @override
  Future<Either<Failure, void>> call(ControlLedParams params) async {
    return repository.controlLed(params.deviceId, params.action);
  }
}

class ControlLedParams extends Params {
  const ControlLedParams({
    required this.deviceId,
    required this.action,
  });

  final String deviceId;
  final LedAction action;

  @override
  List<Object> get props => [deviceId, action];
}
