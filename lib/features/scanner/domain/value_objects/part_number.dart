import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';

class PartNumber extends Equatable {

  const PartNumber._(this.value);
  final String value;

  static Either<Failure, PartNumber> create(String input) {
    final cleaned = _clean(input);
    
    if (!_isValid(cleaned)) {
      return const Left(ValidationFailure(message: 'Invalid part number format'));
    }
    
    return Right(PartNumber._(cleaned));
  }

  static String _clean(String input) {
    // Remove common prefixes
    var cleaned = input.toUpperCase();
    cleaned = cleaned.replaceAll(RegExp(r'^P/N:?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^PN:?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^PART:?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^MODEL:?\s*'), '');
    
    // Remove excessive whitespace but keep single spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  static bool _isValid(String part) {
    // Part numbers should be at least 3 characters
    if (part.length < 3) {
      return false;
    }
    
    // Part numbers typically contain alphanumeric chars, dashes, slashes
    final pattern = RegExp(r'^[A-Z0-9\-/\s]+$');
    return pattern.hasMatch(part);
  }

  String get displayValue => value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}

// ValidationFailure is already defined in core/errors/failures.dart