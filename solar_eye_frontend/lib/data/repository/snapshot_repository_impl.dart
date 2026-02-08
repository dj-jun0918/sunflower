import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';
import 'package:solar_eye_frontend/domain/repository/snapshot_repository.dart';

class SnapshotRepositoryImpl implements SnapshotRepository {
  final Dio _dio;

  SnapshotRepositoryImpl(this._dio);

  @override
  Future<void> saveAnalysisSnapshot({
    required String imagePath,
    required String panelId,
    required List<Map<String, dynamic>> detections,
  }) async {
    try {
      final formData = FormData.fromMap({
        'panel_id': panelId,
        'image': await MultipartFile.fromFile(imagePath),
        'detections': detections,
      });

      await _dio.post('/api/v1/analysis/snapshot', data: formData);
    } catch (e) {
      throw Exception('Failed to save snapshot: $e');
    }
  }
}
