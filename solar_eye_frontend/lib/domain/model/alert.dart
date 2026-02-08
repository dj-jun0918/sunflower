import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

/// 알림 모델
@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String title,
    required String message,
    required AlertSeverity severity,
    required DateTime createdAt,
    @Default(false) bool isRead,
    String? panelId,
    String? panelName,
    String? detectionId,
    String? snapshotUrl,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}

/// 알림 심각도
enum AlertSeverity {
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('danger')
  danger,
}

/// 알림 목록 응답
@freezed
class AlertsResponse with _$AlertsResponse {
  const factory AlertsResponse({
    required List<Alert> alerts,
    required int total,
    required int unreadCount,
  }) = _AlertsResponse;

  factory AlertsResponse.fromJson(Map<String, dynamic> json) =>
      _$AlertsResponseFromJson(json);
}
