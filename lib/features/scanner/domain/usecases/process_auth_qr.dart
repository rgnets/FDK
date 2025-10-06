import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';

/// Use case for processing authentication QR codes
final class ProcessAuthQr extends UseCase<AuthCredentials, ProcessAuthQrParams> {
  const ProcessAuthQr();
  
  @override
  Future<Either<Failure, AuthCredentials>> call(ProcessAuthQrParams params) async {
    try {
      final code = params.qrCode;
      
      // Try to parse as JSON
      if (code.startsWith('{') && code.endsWith('}')) {
        final json = jsonDecode(code) as Map<String, dynamic>;
        return _extractCredentialsFromJson(json);
      }
      
      // Try to parse as key=value format
      if (code.contains('=')) {
        return _extractCredentialsFromKeyValue(code);
      }
      
      return const Left(ValidationFailure(message: 'Invalid QR code format'));
    } on FormatException catch (e) {
      return Left(ValidationFailure(message: 'Failed to parse QR code: $e'));
    } on Exception catch (e) {
      return Left(ValidationFailure(message: 'Error processing QR code: $e'));
    }
  }
  
  Either<Failure, AuthCredentials> _extractCredentialsFromJson(Map<String, dynamic> json) {
    final fqdn = json['fqdn'] as String?;
    final login = json['login'] as String?;
    final apiKey = json['apiKey'] as String?;
    
    if (fqdn == null || login == null || apiKey == null) {
      return const Left(ValidationFailure(message: 'Missing required fields in QR code'));
    }
    
    return Right(AuthCredentials(
      fqdn: fqdn,
      login: login,
      apiKey: apiKey,
    ));
  }
  
  Either<Failure, AuthCredentials> _extractCredentialsFromKeyValue(String code) {
    final credentials = <String, String>{};
    final lines = code.split('\n');
    
    for (final line in lines) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          credentials[key] = value;
        }
      }
    }
    
    final fqdn = credentials['fqdn'];
    final login = credentials['login'];
    final apiKey = credentials['apiKey'];
    
    if (fqdn == null || login == null || apiKey == null) {
      return const Left(ValidationFailure(message: 'Missing required fields in QR code'));
    }
    
    return Right(AuthCredentials(
      fqdn: fqdn,
      login: login,
      apiKey: apiKey,
    ));
  }
}

/// Parameters for processing auth QR
class ProcessAuthQrParams {
  const ProcessAuthQrParams({required this.qrCode});
  final String qrCode;
}

/// Auth credentials extracted from QR code
class AuthCredentials {
  const AuthCredentials({
    required this.fqdn,
    required this.login,
    required this.apiKey,
  });
  
  final String fqdn;
  final String login;
  final String apiKey;
}