import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';

/// Use case for processing authentication QR codes.
final class ProcessAuthQr
    extends UseCase<AuthCredentials, ProcessAuthQrParams> {
  ProcessAuthQr({DateTime Function()? clock, Duration? allowedDrift})
    : _now = clock ?? DateTime.now,
      _allowedDrift = allowedDrift ?? const Duration(minutes: 15);

  final DateTime Function() _now;
  final Duration _allowedDrift;

  static const _timestampKey = 'timestamp';
  static const _apiKeyKey = 'api_key';
  static const _apiKeyAltKey = 'apiKey';
  static const _siteKey = 'site_name';
  static const _siteAltKey = 'siteName';
  static const _loginKey = 'login';
  static const _fqdnKey = 'fqdn';
  static const _signatureKey = 'signature';

  @override
  Future<Either<Failure, AuthCredentials>> call(
    ProcessAuthQrParams params,
  ) async {
    try {
      final code = params.qrCode.trim();
      if (code.isEmpty) {
        return const Left(ValidationFailure(message: 'QR code is empty'));
      }

      // Try to parse as JSON.
      if (code.startsWith('{') && code.endsWith('}')) {
        final json = jsonDecode(code) as Map<String, dynamic>;
        return _extractCredentialsFromJson(json);
      }

      // Try to parse as key=value format.
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

  Either<Failure, AuthCredentials> _extractCredentialsFromJson(
    Map<String, dynamic> json,
  ) {
    final fqdn = json[_fqdnKey] as String?;
    final login = json[_loginKey] as String?;
    final apiKey = (json[_apiKeyKey] ?? json[_apiKeyAltKey]) as String?;
    final siteName = (json[_siteKey] ?? json[_siteAltKey]) as String?;
    final timestamp = json[_timestampKey] as String?;
    final signature = json[_signatureKey] as String?;

    return _buildCredentials(
      fqdn: fqdn,
      login: login,
      apiKey: apiKey,
      siteName: siteName,
      timestamp: timestamp,
      signature: signature,
    );
  }

  Either<Failure, AuthCredentials> _extractCredentialsFromKeyValue(
    String code,
  ) {
    final credentials = <String, String>{};
    final lines = code.split(RegExp(r'[\r\n]+'));

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || !line.contains('=')) {
        continue;
      }

      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0 || separatorIndex == line.length - 1) {
        continue;
      }

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      if (key.isNotEmpty) {
        credentials[key] = value;
      }
    }

    final fqdn = credentials[_fqdnKey];
    final login = credentials[_loginKey];
    final apiKey = credentials[_apiKeyKey] ?? credentials[_apiKeyAltKey];
    final siteName = credentials[_siteKey] ?? credentials[_siteAltKey];
    final timestamp = credentials[_timestampKey];
    final signature = credentials[_signatureKey];

    return _buildCredentials(
      fqdn: fqdn,
      login: login,
      apiKey: apiKey,
      siteName: siteName,
      timestamp: timestamp,
      signature: signature,
    );
  }

  Either<Failure, AuthCredentials> _buildCredentials({
    required String? fqdn,
    required String? login,
    required String? apiKey,
    required String? siteName,
    required String? timestamp,
    required String? signature,
  }) {
    if (fqdn == null || fqdn.isEmpty) {
      return const Left(ValidationFailure(message: 'QR code missing fqdn'));
    }
    if (!_isValidHost(fqdn)) {
      return const Left(ValidationFailure(message: 'Invalid fqdn in QR code'));
    }

    if (login == null || login.isEmpty) {
      return const Left(ValidationFailure(message: 'QR code missing login'));
    }

    if (apiKey == null || apiKey.isEmpty) {
      return const Left(ValidationFailure(message: 'QR code missing api key'));
    }

    final normalizedSite = siteName?.trim();
    final resolvedSite = (normalizedSite == null || normalizedSite.isEmpty)
        ? login
        : normalizedSite;

    final now = _now().toUtc();

    DateTime issuedAt;
    final rawTimestamp = timestamp?.trim();
    if (rawTimestamp == null || rawTimestamp.isEmpty) {
      issuedAt = now;
    } else {
      final parsed = DateTime.tryParse(rawTimestamp)?.toUtc();
      if (parsed == null) {
        issuedAt = now;
      } else {
        final drift = now.difference(parsed).abs();
        if (drift > _allowedDrift) {
          return Left(
            ValidationFailure(
              message: 'QR code expired (${drift.inMinutes} minutes old)',
            ),
          );
        }
        issuedAt = parsed;
      }
    }

    return Right(
      AuthCredentials(
        fqdn: fqdn,
        login: login,
        apiKey: apiKey,
        siteName: resolvedSite,
        issuedAt: issuedAt,
        signature: signature,
      ),
    );
  }

  bool _isValidHost(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse('https://$trimmed');
    if (uri == null || uri.host.isEmpty || uri.host.contains(' ')) {
      return false;
    }
    final hostPattern = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    );
    return hostPattern.hasMatch(uri.host);
  }
}

/// Parameters for processing auth QR.
class ProcessAuthQrParams {
  const ProcessAuthQrParams({required this.qrCode});
  final String qrCode;
}

/// Auth credentials extracted from QR code.
class AuthCredentials {
  const AuthCredentials({
    required this.fqdn,
    required this.login,
    required this.apiKey,
    required this.siteName,
    required this.issuedAt,
    this.signature,
  });

  final String fqdn;
  final String login;
  final String apiKey;
  final String siteName;
  final DateTime issuedAt;
  final String? signature;
}
