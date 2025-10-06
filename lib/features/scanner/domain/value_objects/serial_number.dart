import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';

class SerialNumber extends Equatable {

  const SerialNumber._(this.value);
  final String value;

  static Either<Failure, SerialNumber> create(String input) {
    final cleaned = _clean(input);
    
    if (!_isValid(cleaned)) {
      return const Left(ValidationFailure(message: 'Invalid serial number format'));
    }
    
    return Right(SerialNumber._(cleaned));
  }

  static String _clean(String input) {
    // Remove common prefixes
    var cleaned = input.toUpperCase();
    cleaned = cleaned.replaceAll(RegExp(r'^S/N:?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^SN:?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^SERIAL:?\s*'), '');
    
    // Remove whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    
    return cleaned;
  }

  static bool _isValid(String serial) {
    // Serial numbers should be alphanumeric, 6-30 characters
    if (serial.length < 6 || serial.length > 30) {
      return false;
    }
    
    // Must contain at least some alphanumeric characters
    final pattern = RegExp(r'^[A-Z0-9]+$');
    return pattern.hasMatch(serial);
  }

  String get displayValue => value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}

// ValidationFailure is already defined in core/errors/failures.dart