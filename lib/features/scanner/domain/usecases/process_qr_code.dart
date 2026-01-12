import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/barcode_type.dart';

/// Use case for processing QR code data
final class ProcessQrCode extends UseCase<ProcessQrCodeResult, ProcessQrCodeParams> {
  const ProcessQrCode();
  
  @override
  Future<Either<Failure, ProcessQrCodeResult>> call(ProcessQrCodeParams params) async {
    try {
      final code = params.code;
      
      // Check if it's an auth code
      if (_isAuthCode(code)) {
        final credentials = _parseAuthCredentials(code);
        if (credentials != null) {
          return Right(ProcessQrCodeResult.auth(credentials));
        }
      }
      
      // Determine barcode type
      final barcodeType = _determineBarcodeType(code);
      return Right(ProcessQrCodeResult.device(
        code: code,
        type: barcodeType,
      ));
    } on Exception catch (e) {
      return Left(ValidationFailure(message: 'Failed to process QR code: $e'));
    }
  }
  
  bool _isAuthCode(String code) {
    // Accept 'token' or legacy 'apiKey' for backward compatibility
    return code.contains('fqdn') && (code.contains('token') || code.contains('apiKey')) ||
           code.startsWith('{') && code.contains('"fqdn"');
  }
  
  Map<String, dynamic>? _parseAuthCredentials(String code) {
    try {
      // Try JSON format
      if (code.startsWith('{')) {
        return json.decode(code) as Map<String, dynamic>;
      }
      
      // Try custom format (key=value pairs)
      final result = <String, dynamic>{};
      final lines = code.split('\n');
      
      for (final line in lines) {
        if (line.contains('=')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            result[key] = value;
          }
        }
      }
      
      // Accept 'token' or legacy 'apiKey' for backward compatibility
      if (result.containsKey('fqdn') && (result.containsKey('token') || result.containsKey('apiKey'))) {
        return result;
      }
      
      return null;
    } on Exception {
      return null;
    }
  }
  
  BarcodeType _determineBarcodeType(String code) {
    final upperCode = code.toUpperCase();
    
    // MAC address pattern
    if (RegExp(r'^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$').hasMatch(upperCode)) {
      return BarcodeType.macAddress;
    }
    
    // Serial number patterns
    if (upperCode.startsWith('S/N:') || upperCode.startsWith('SN:')) {
      return BarcodeType.serialNumber;
    }
    
    // Default to serial for other formats
    return BarcodeType.serialNumber;
  }
}

/// Parameters for processing QR code
class ProcessQrCodeParams {
  const ProcessQrCodeParams({required this.code});
  final String code;
}

/// Result of QR code processing
sealed class ProcessQrCodeResult {
  const ProcessQrCodeResult();
  
  const factory ProcessQrCodeResult.auth(Map<String, dynamic> credentials) = AuthResult;
  const factory ProcessQrCodeResult.device({
    required String code,
    required BarcodeType type,
  }) = DeviceResult;
}

class AuthResult extends ProcessQrCodeResult {
  const AuthResult(this.credentials);
  final Map<String, dynamic> credentials;
}

class DeviceResult extends ProcessQrCodeResult {
  const DeviceResult({required this.code, required this.type});
  final String code;
  final BarcodeType type;
}