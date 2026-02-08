import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/detection_repository_impl.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';
import 'package:solar_eye_frontend/domain/repository/detection_repository.dart';

part 'detection_provider.g.dart';

/// DetectionRepository Provider
@riverpod
DetectionRepository detectionRepository(DetectionRepositoryRef ref) {
  final dio = ref.watch(apiClientProvider);
  return DetectionRepositoryImpl(dio);
}

/// 탐지 목록 Provider
@riverpod
class DetectionList extends _$DetectionList {
  @override
  Future<DetectionsResponse> build({
    int page = 1,
    String? panelId,
    DetectionType? type,
  }) async {
    final repository = ref.watch(detectionRepositoryProvider);
    return repository.getDetections(
      page: page,
      panelId: panelId,
      type: type,
    );
  }
}

/// 탐지 상세 Provider
@riverpod
Future<Detection> detectionDetail(
    DetectionDetailRef ref, String detectionId) async {
  final repository = ref.watch(detectionRepositoryProvider);
  return repository.getDetection(detectionId);
}
