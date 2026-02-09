// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalysisSessionImpl _$$AnalysisSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$AnalysisSessionImpl(
      id: json['id'] as String,
      panelId: _idToString(json['panel_id']),
      type: json['type'] as String,
      status: json['status'] as String,
      originalImageUrl: json['original_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      detections: (json['detections'] as List<dynamic>?)
              ?.map((e) => Detection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AnalysisSessionImplToJson(
        _$AnalysisSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'panel_id': instance.panelId,
      'type': instance.type,
      'status': instance.status,
      'original_image_url': instance.originalImageUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'detections': instance.detections,
    };

_$AnalysisHistoryResponseImpl _$$AnalysisHistoryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$AnalysisHistoryResponseImpl(
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => AnalysisSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AnalysisHistoryResponseImplToJson(
        _$AnalysisHistoryResponseImpl instance) =>
    <String, dynamic>{
      'sessions': instance.sessions,
    };
