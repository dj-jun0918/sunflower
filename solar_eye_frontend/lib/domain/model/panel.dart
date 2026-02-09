import 'package:freezed_annotation/freezed_annotation.dart';

part 'panel.freezed.dart';
part 'panel.g.dart';

/// ID 변환 헬퍼 (int -> String)
String _idToString(dynamic value) => value.toString();

/// 태양광 패널 모델
@freezed
class Panel with _$Panel {
  const factory Panel({
    @JsonKey(fromJson: _idToString) required String id,
    required String name,
    String? location,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'rtsp_url') String? rtspUrl,
    @Default(PanelStatus.normal) PanelStatus status,
    @JsonKey(name: 'last_detection_at') DateTime? lastDetectionAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Panel;

  factory Panel.fromJson(Map<String, dynamic> json) => _$PanelFromJson(json);
}

/// 패널 상태
enum PanelStatus {
  @JsonValue('active')
  normal,
  @JsonValue('maintenance')
  warning,
  @JsonValue('error')
  danger,
  @JsonValue('inactive')
  inactive,
}

/// 패널 생성/수정 요청
@freezed
class PanelRequest with _$PanelRequest {
  const factory PanelRequest({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'rtsp_url') String? rtspUrl,
  }) = _PanelRequest;

  factory PanelRequest.fromJson(Map<String, dynamic> json) =>
      _$PanelRequestFromJson(json);
}
