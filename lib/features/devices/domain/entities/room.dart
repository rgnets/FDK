import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';

/// Entity representing a room in the property management system
/// Maps to the pms_room object returned by the API
@freezed
class Room with _$Room {
  const factory Room({
    required int id,
    required String name,
    String? building,
    String? floor,
    String? number,
    String? description,
    String? location,
    List<String>? deviceIds,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Room;

  const Room._();

  /// Extract building information from the name field
  /// API returns format like "(Interurban) 007" or "(North Tower) 101"
  String? get extractedBuilding {
    if (building != null) {
      return building;
    }

    final match = RegExp(r'\(([^)]+)\)').firstMatch(name);
    return match?.group(1);
  }

  /// Extract room number from the name field
  String? get extractedNumber {
    if (number != null) {
      return number;
    }

    final parts = name.split(')');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return null;
  }

  /// Get a formatted display name
  String get displayName {
    final bldg = extractedBuilding;
    final num = extractedNumber;

    if (bldg != null && num != null) {
      return '$bldg Room $num';
    }
    return name;
  }

  /// Get a short display name (just room number if available)
  String get shortName {
    return extractedNumber ?? name;
  }
}
