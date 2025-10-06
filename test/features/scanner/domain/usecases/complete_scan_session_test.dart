import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/complete_scan_session.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late CompleteScanSession usecase;
  late MockScannerRepository mockRepository;

  setUp(() {
    mockRepository = MockScannerRepository();
    usecase = CompleteScanSession(mockRepository);
  });

  group('CompleteScanSession', () {
    const tSessionId = 'session-123';
    const tDeviceData = {
      'serialNumber': 'SN123456',
      'macAddress': '00:11:22:33:44:55',
      'partNumber': 'PN789012',
      'assetTag': 'AT345678',
    };
    const tParams = CompleteScanSessionParams(
      sessionId: tSessionId,
      deviceData: tDeviceData,
    );

    test('should complete scan session successfully', () async {
      // arrange
      when(() => mockRepository.completeSession(tSessionId, tDeviceData))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when session completion fails', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Failed to complete scan session',
        statusCode: 500,
      );
      when(() => mockRepository.completeSession(tSessionId, tDeviceData))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when device data is invalid', () async {
      // arrange
      const tFailure = ValidationFailure(
        message: 'Invalid device data provided',
        statusCode: 400,
      );
      when(() => mockRepository.completeSession(tSessionId, tDeviceData))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when session not found', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Scan session not found',
        statusCode: 404,
      );
      when(() => mockRepository.completeSession(tSessionId, tDeviceData))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when session is already completed', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Scan session is already completed',
        statusCode: 400,
      );
      when(() => mockRepository.completeSession(tSessionId, tDeviceData))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache operation fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to update session cache',
      );
      when(() => mockRepository.completeSession(tSessionId, tDeviceData))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct parameters to repository', () async {
      // arrange
      when(() => mockRepository.completeSession(any(), any()))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.completeSession(tSessionId, tDeviceData)).called(1);
    });

    test('should handle empty device data', () async {
      // arrange
      const tEmptyData = <String, dynamic>{};
      const tEmptyParams = CompleteScanSessionParams(
        sessionId: tSessionId,
        deviceData: tEmptyData,
      );
      when(() => mockRepository.completeSession(tSessionId, tEmptyData))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tEmptyParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.completeSession(tSessionId, tEmptyData)).called(1);
    });

    group('CompleteScanSessionParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = CompleteScanSessionParams(
          sessionId: tSessionId,
          deviceData: tDeviceData,
        );
        const params2 = CompleteScanSessionParams(
          sessionId: tSessionId,
          deviceData: tDeviceData,
        );
        const params3 = CompleteScanSessionParams(
          sessionId: 'different-id',
          deviceData: tDeviceData,
        );

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tSessionId, tDeviceData]);
      });
    });
  });
}