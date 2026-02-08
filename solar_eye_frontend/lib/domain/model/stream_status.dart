import 'package:freezed_annotation/freezed_annotation.dart';

part 'stream_status.freezed.dart';
part 'stream_status.g.dart';

/// 스트림 상태 모델
@freezed
class StreamStatus with _$StreamStatus {
  const factory StreamStatus({
    required String panelId,
    required String panelName,
    required StreamState state,
    String? rtspUrl,
    String? errorMessage,
    DateTime? lastFrameAt,
  }) = _StreamStatus;

  factory StreamStatus.fromJson(Map<String, dynamic> json) =>
      _$StreamStatusFromJson(json);
}

/// 스트림 연결 상태
enum StreamState {
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('connecting')
  connecting,
  @JsonValue('connected')
  connected,
  @JsonValue('error')
  error,
}

/// AI 탐지 결과 (실시간 오버레이용)
@freezed
class DetectionResult with _$DetectionResult {
  const factory DetectionResult({
    required String id,
    required String label,
    required double confidence,
    required BoundingBox bbox,
    required DateTime timestamp,
  }) = _DetectionResult;

  factory DetectionResult.fromJson(Map<String, dynamic> json) =>
      _$DetectionResultFromJson(json);
}

/// 바운딩 박스
@freezed
class BoundingBox with _$BoundingBox {
  const factory BoundingBox({
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);
}
