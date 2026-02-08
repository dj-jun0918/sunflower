import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/data/repository/snapshot_repository_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late SnapshotRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = SnapshotRepositoryImpl(mockDio);
  });

  group('SnapshotRepositoryImpl', () {
    test('saveAnalysisSnapshot sends correct data', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      // Act
      await repository.saveAnalysisSnapshot(
        imagePath: 'test_path.jpg',
        panelId: 'panel_001',
        detections: [
          {'type': 'crack', 'confidence': 0.9}
        ],
      );

      // Assert
      verify(() => mockDio.post(
            '/api/v1/analysis/snapshot',
            data: any(named: 'data'),
          )).called(1);
    });
  });
}
