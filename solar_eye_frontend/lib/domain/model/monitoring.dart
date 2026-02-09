import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';

part 'monitoring.freezed.dart';
part 'monitoring.g.dart';

/// ID 변환 헬퍼 (int -> String)
String _idToString(dynamic value) => value.toString();

@freezed
class AnalysisSession with _$AnalysisSession {
  const factory AnalysisSession({
    required String id,
    @JsonKey(name: 'panel_id', fromJson: _idToString) required String panelId,
    required String type, // "cctv" or "drone"
    required String status, // "processing", "completed", "failed"
    @JsonKey(name: 'original_image_url') String? originalImageUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<Detection> detections,
  }) = _AnalysisSession;

  factory AnalysisSession.fromJson(Map<String, dynamic> json) =>
      _$AnalysisSessionFromJson(json);
}

@freezed
class AnalysisHistoryResponse with _$AnalysisHistoryResponse {
  const factory AnalysisHistoryResponse({
    required List<AnalysisSession> sessions,
  }) = _AnalysisHistoryResponse;

  factory AnalysisHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisHistoryResponseFromJson(json);
}
