import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';

/// Use case for filtering devices based on criteria
final class FilterDevices extends UseCase<List<Device>, FilterDevicesParams> {
  @override
  Future<Either<Failure, List<Device>>> call(FilterDevicesParams params) async {
    try {
      var filtered = params.devices;
      
      // Apply search filter with optimized string operations
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        final query = params.searchQuery!.toLowerCase();
        filtered = filtered.where((device) {
          // Cache lowercase values to avoid repeated operations
          final nameLower = device.name.toLowerCase();
          final typeLower = device.type.toLowerCase();
          final locationLower = device.location?.toLowerCase();
          final ipLower = device.ipAddress?.toLowerCase();
          final macLower = device.macAddress?.toLowerCase();
          
          return nameLower.contains(query) ||
                 typeLower.contains(query) ||
                 (locationLower?.contains(query) ?? false) ||
                 (ipLower?.contains(query) ?? false) ||
                 (macLower?.contains(query) ?? false);
        }).toList();
      }
      
      // Apply type filter
      if (params.typeFilter != null && params.typeFilter!.isNotEmpty) {
        filtered = filtered.where((device) {
          return params.typeFilter!.contains(device.type);
        }).toList();
      }
      
      // Apply status filter
      if (params.statusFilter != null && params.statusFilter!.isNotEmpty) {
        filtered = filtered.where((device) {
          return params.statusFilter!.contains(device.status);
        }).toList();
      }
      
      // Apply location filter
      if (params.locationFilter != null && params.locationFilter!.isNotEmpty) {
        filtered = filtered.where((device) {
          return device.location != null && 
                 params.locationFilter!.contains(device.location);
        }).toList();
      }
      
      // Apply sorting with direction
      if (params.sortBy != null) {
        final sortMultiplier = params.sortDescending ? -1 : 1;
        
        switch (params.sortBy!) {
          case DeviceSortBy.name:
            filtered.sort((a, b) => 
              sortMultiplier * a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            break;
          case DeviceSortBy.type:
            filtered.sort((a, b) => 
              sortMultiplier * a.type.compareTo(b.type));
            break;
          case DeviceSortBy.status:
            filtered.sort((a, b) => 
              sortMultiplier * a.status.compareTo(b.status));
            break;
          case DeviceSortBy.location:
            filtered.sort((a, b) => 
              sortMultiplier * (a.location ?? '').compareTo(b.location ?? ''));
            break;
        }
      }
      
      return Right(filtered);
    } on Exception catch (e) {
      return Left(ValidationFailure(message: 'Failed to filter devices: $e'));
    }
  }
}

/// Parameters for filtering devices
class FilterDevicesParams {
  const FilterDevicesParams({
    required this.devices,
    this.searchQuery,
    this.typeFilter,
    this.statusFilter,
    this.locationFilter,
    this.sortBy,
    this.sortDescending = false,
  });
  
  final List<Device> devices;
  final String? searchQuery;
  final Set<String>? typeFilter;
  final Set<String>? statusFilter;
  final Set<String>? locationFilter;
  final DeviceSortBy? sortBy;
  final bool sortDescending;
}

/// Sort options for devices
enum DeviceSortBy {
  name,
  type,
  status,
  location,
}