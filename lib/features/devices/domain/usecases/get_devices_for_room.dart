import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

/// Use case for getting all devices associated with a specific room.
/// Follows Clean Architecture principles by depending only on abstractions.
class GetDevicesForRoom {
  const GetDevicesForRoom(this._repository);
  
  final DeviceRepository _repository;
  
  /// Gets all devices for the specified room ID.
  /// Returns a sorted list of devices or a failure.
  Future<Either<Failure, List<Device>>> call(int roomId) async {
    // Validate input
    if (roomId <= 0) {
      return const Left(
        ValidationFailure(
          message: 'Invalid room ID: must be a positive integer',
        ),
      );
    }
    
    try {
      // Get all devices from repository
      final result = await _repository.getDevices();
      
      return result.fold(
        // Pass through any repository failures
        Left.new,
        // Filter and sort devices for the room
        (devices) {
          final roomDevices = devices
              .where((device) => device.pmsRoomId == roomId)
              .toList()
            // Sort by type first, then by name for consistent display
            ..sort((a, b) {
              final typeCompare = a.type.compareTo(b.type);
              return typeCompare != 0 ? typeCompare : a.name.compareTo(b.name);
            });
          
          return Right(roomDevices);
        },
      );
    } on Exception catch (e) {
      // Catch any unexpected errors
      return Left(
        ServerFailure(
          message: 'Failed to get devices for room: $e',
        ),
      );
    }
  }
}