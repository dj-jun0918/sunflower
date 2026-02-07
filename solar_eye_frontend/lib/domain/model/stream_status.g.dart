// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreamStatusImpl _$$StreamStatusImplFromJson(Map<String, dynamic> json) =>
    _$StreamStatusImpl(
      panelId: json['panelId'] as String,
      panelName: json['panelName'] as String,
      state: $enumDecode(_$StreamStateEnumMap, json['state']),
      rtspUrl: json['rtspUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      lastFrameAt: json['lastFrameAt'] == null
          ? null
          : DateTime.parse(json['lastFrameAt'] as String),
    );

Map<String, dynamic> _$$StreamStatusImplToJson(_$StreamStatusImpl instance) =>
    <String, dynamic>{
      'panelId': instance.panelId,
      'panelName': instance.panelName,
      'state': _$StreamStateEnumMap[instance.state]!,
      'rtspUrl': instance.rtspUrl,
      'errorMessage': instance.errorMessage,
      'lastFrameAt': instance.lastFrameAt?.toIso8601String(),
    };

const _$StreamStateEnumMap = {
  StreamState.disconnected: 'disconnected',
  StreamState.connecting: 'connecting',
  StreamState.connected: 'connected',
  StreamState.error: 'error',
};

_$DetectionResultImpl _$$DetectionResultImplFromJson(
        Map<String, dynamic> json) =>
    _$DetectionResultImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      bbox: BoundingBox.fromJson(json['bbox'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$DetectionResultImplToJson(
        _$DetectionResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'confidence': instance.confidence,
      'bbox': instance.bbox,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_$BoundingBoxImpl _$$BoundingBoxImplFromJson(Map<String, dynamic> json) =>
    _$BoundingBoxImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$BoundingBoxImplToJson(_$BoundingBoxImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };
