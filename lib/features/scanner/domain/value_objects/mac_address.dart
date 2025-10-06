import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';

class MacAddress extends Equatable {

  const MacAddress._(this.value);
  final String value;

  static Either<Failure, MacAddress> create(String input) {
    final normalized = _normalize(input);
    
    if (!_isValid(normalized)) {
      return const Left(ValidationFailure(message: 'Invalid MAC address format'));
    }
    
    return Right(MacAddress._(normalized));
  }

  static String _normalize(String input) {
    // Remove all separators and convert to uppercase
    final mac = input.replaceAll(RegExp('[:-]'), '').toUpperCase();
    
    // Format as XX:XX:XX:XX:XX:XX
    if (mac.length == 12) {
      final parts = <String>[];
      for (var i = 0; i < 12; i += 2) {
        parts.add(mac.substring(i, i + 2));
      }
      return parts.join(':');
    }
    
    return input;
  }

  static bool _isValid(String mac) {
    final pattern = RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$');
    return pattern.hasMatch(mac);
  }

  String get displayValue => value;
  
  String get compactValue => value.replaceAll(':', '');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}

// ValidationFailure is already defined in core/errors/failures.dart