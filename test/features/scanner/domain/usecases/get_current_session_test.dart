import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/get_current_session.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late GetCurrentSession usecase;
  late MockScannerRepository mockRepository;

  setUp(() {
    mockRepository = MockScannerRepository();
    usecase = GetCurrentSession(mockRepository);
  });

  group('GetCurrentSession', () {
    final tScanSession = ScanSession(
      id: 'session-123',
      deviceType: DeviceType.accessPoint,
      startedAt: DateTime(2024, 1, 1, 10, 0, 0),
      completedAt: null,
      scannedBarcodes: [
        ScanResult(
          id: 'result-1',
          barcode: 'SN123456',
          type: BarcodeType.serialNumber,
          value: 'SN123456',
          scannedAt: DateTime(2024, 1, 1, 10, 1, 0),
        ),
      ],
      status: ScanSessionStatus.scanning,
      serialNumber: 'SN123456',
      macAddress: null,
      partNumber: null,
      assetTag: null,
    );

    test('should get current scan session successfully', () async {
      // arrange
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => Right<Failure, ScanSession?>(tScanSession));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, Right<Failure, ScanSession?>(tScanSession));
      verify(() => mockRepository.getCurrentSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no current session exists', () async {
      // arrange
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => const Right<Failure, ScanSession?>(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, ScanSession?>(null));
      verify(() => mockRepository.getCurrentSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when repository fails', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Failed to retrieve current session',
        statusCode: 500,
      );
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => const Left<Failure, ScanSession?>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, ScanSession?>(tFailure));
      verify(() => mockRepository.getCurrentSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read session from cache',
      );
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => const Left<Failure, ScanSession?>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, ScanSession?>(tFailure));
      verify(() => mockRepository.getCurrentSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return completed session when session is finished', () async {
      // arrange
      final tCompletedSession = ScanSession(
        id: 'session-456',
        deviceType: DeviceType.accessPoint,
        startedAt: DateTime(2024, 1, 1, 10, 0, 0),
        completedAt: DateTime(2024, 1, 1, 10, 5, 0),
        scannedBarcodes: [
          ScanResult(
            id: 'result-1',
            barcode: 'SN123456',
            type: BarcodeType.serialNumber,
            value: 'SN123456',
            scannedAt: DateTime(2024, 1, 1, 10, 1, 0),
          ),
          ScanResult(
            id: 'result-2',
            barcode: '00:11:22:33:44:55',
            type: BarcodeType.macAddress,
            value: '00:11:22:33:44:55',
            scannedAt: DateTime(2024, 1, 1, 10, 2, 0),
          ),
        ],
        status: ScanSessionStatus.complete,
        serialNumber: 'SN123456',
        macAddress: '00:11:22:33:44:55',
        partNumber: null,
        assetTag: null,
      );
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => Right<Failure, ScanSession?>(tCompletedSession));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, Right<Failure, ScanSession?>(tCompletedSession));
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) {
          expect(session?.status, ScanSessionStatus.complete);
          expect(session?.isComplete, true);
          expect(session?.duration, isNotNull);
        },
      );
      verify(() => mockRepository.getCurrentSession()).called(1);
    });

    test('should return session with different device types', () async {
      // arrange
      final tOntSession = ScanSession(
        id: 'session-ont',
        deviceType: DeviceType.ont,
        startedAt: DateTime(2024, 1, 1, 10, 0, 0),
        completedAt: null,
        scannedBarcodes: [],
        status: ScanSessionStatus.scanning,
        serialNumber: null,
        macAddress: null,
        partNumber: null,
        assetTag: null,
      );
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => Right<Failure, ScanSession?>(tOntSession));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, Right<Failure, ScanSession?>(tOntSession));
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) => expect(session?.deviceType, DeviceType.ont),
      );
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => Right<Failure, ScanSession?>(tScanSession));

      // act
      await usecase(const NoParams());

      // assert
      verify(() => mockRepository.getCurrentSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}