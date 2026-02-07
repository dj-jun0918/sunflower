import 'package:freezed_annotation/freezed_annotation.dart';

part 'detection.freezed.dart';
part 'detection.g.dart';

/// 탐지 모델
@freezed
class Detection with _$Detection {
  const factory Detection({
    required String id,
    required String panelId,
    required String panelName,
    required DetectionType type,
    required double confidence,
    required DateTime detectedAt,
    String? imageUrl,
    String? alertId,
  }) = _Detection;

  factory Detection.fromJson(Map<String, dynamic> json) =>
      _$DetectionFromJson(json);
}

/// 탐지 유형
enum DetectionType {
  @JsonValue('normal')
  normal,
  @JsonValue('soiling')
  soiling,
  @JsonValue('crack')
  crack,
}

/// 탐지 목록 응답
@freezed
class DetectionsResponse with _$DetectionsResponse {
  const factory DetectionsResponse({
    required List<Detection> detections,
    required int total,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _DetectionsResponse;

  factory DetectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$DetectionsResponseFromJson(json);
}
