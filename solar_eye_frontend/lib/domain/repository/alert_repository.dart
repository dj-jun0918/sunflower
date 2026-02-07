import 'package:solar_eye_frontend/domain/model/alert.dart';

/// 알림 Repository 인터페이스
abstract class AlertRepository {
  /// 알림 목록 가져오기
  Future<AlertsResponse> getAlerts({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  });

  /// 알림 상세 가져오기
  Future<Alert> getAlert(String id);

  /// 알림 읽음 처리
  Future<void> markAsRead(String id);

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead();

  /// 알림 삭제
  Future<void> deleteAlert(String id);
}
