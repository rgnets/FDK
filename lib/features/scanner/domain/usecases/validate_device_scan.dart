import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

final class ValidateDeviceScan extends UseCase<bool, ValidateDeviceScanParams> {
  ValidateDeviceScan();

  @override
  Future<Either<Failure, bool>> call(ValidateDeviceScanParams params) async {
    final session = params.scanSession;
    
    // Check if we have the minimum required fields for the device type
    switch (session.deviceType) {
      case DeviceType.accessPoint:
      case DeviceType.ont:
        // AP and ONT require both serial number and MAC address
        final isValid = session.serialNumber != null && 
                       session.serialNumber!.isNotEmpty &&
                       session.macAddress != null &&
                       session.macAddress!.isNotEmpty;
        return Right(isValid);
        
      case DeviceType.switchDevice:
        // Switch only requires serial number
        final isValid = session.serialNumber != null && 
                       session.serialNumber!.isNotEmpty;
        return Right(isValid);
    }
  }
}

class ValidateDeviceScanParams extends Equatable {

  const ValidateDeviceScanParams({required this.scanSession});
  final ScanSession scanSession;

  @override
  List<Object?> get props => [scanSession];
}