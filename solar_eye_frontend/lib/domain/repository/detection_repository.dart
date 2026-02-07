import 'package:solar_eye_frontend/domain/model/detection.dart';

/// 탐지 Repository 인터페이스
abstract class DetectionRepository {
  /// 탐지 목록 가져오기
  Future<DetectionsResponse> getDetections({
    int page = 1,
    int limit = 20,
    String? panelId,
    DetectionType? type,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 탐지 상세 가져오기
  Future<Detection> getDetection(String id);
}
