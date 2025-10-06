import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/utils/device_type_utils.dart';
import 'package:rgnets_fdk/features/home/domain/entities/home_statistics.dart';

/// Use case for calculating home screen statistics
final class CalculateHomeStatistics extends UseCase<HomeStatistics, CalculateHomeStatisticsParams> {
  @override
  Future<Either<Failure, HomeStatistics>> call(CalculateHomeStatisticsParams params) async {
    // Use Future.value for synchronous calculation to maintain async contract
    return Future.value(_calculate(params));
  }
  
  Either<Failure, HomeStatistics> _calculate(CalculateHomeStatisticsParams params) {
    try {
      final devices = params.devices;
      
      // Single pass calculation for performance
      var onlineCount = 0;
      var offlineCount = 0;
      var offlineAPCount = 0;
      var offlineSwitchCount = 0;
      var offlineONTCount = 0;
      var missingDocsCount = 0;
      
      for (final device in devices) {
        // Check status
        if (device.status == 'online') {
          onlineCount++;
        } else if (device.status == 'offline') {
          offlineCount++;
          // Check offline device type
          if (DeviceTypeUtils.isAccessPoint(device.type)) {
            offlineAPCount++;
          } else if (DeviceTypeUtils.isSwitch(device.type)) {
            offlineSwitchCount++;
          } else if (DeviceTypeUtils.isONT(device.type)) {
            offlineONTCount++;
          }
        }
        
        // Check documentation
        if (device.images?.isEmpty ?? true) {
          missingDocsCount++;
        }
      }
      
      // Build offline breakdown string
      final String offlineBreakdown;
      if (offlineCount == 0) {
        offlineBreakdown = 'Perfect!';
      } else {
        final parts = <String>[];
        if (offlineAPCount > 0) {
          parts.add('$offlineAPCount AP');
        }
        if (offlineSwitchCount > 0) {
          parts.add('$offlineSwitchCount SW');
        }
        if (offlineONTCount > 0) {
          parts.add('$offlineONTCount ONT');
        }
        offlineBreakdown = parts.isEmpty ? '$offlineCount offline' : parts.join(' - ');
      }
      
      final missingDocsText = missingDocsCount == 0 
        ? 'Perfect!' 
        : '$missingDocsCount missing images';
      
      return Right(HomeStatistics(
        totalDevices: devices.length,
        onlineDevices: onlineCount,
        offlineDevices: offlineCount,
        offlineBreakdown: offlineBreakdown,
        missingDocs: missingDocsCount,
        missingDocsText: missingDocsText,
      ));
    } on FormatException catch (e) {
      return Left(ValidationFailure(message: 'Format error: $e'));
    } on Exception catch (e) {
      return Left(ValidationFailure(message: 'Calculation error: $e'));
    }
  }
}

class CalculateHomeStatisticsParams {
  const CalculateHomeStatisticsParams({required this.devices});
  final List<Device> devices;
}