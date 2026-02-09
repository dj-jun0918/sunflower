// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetectionImpl _$$DetectionImplFromJson(Map<String, dynamic> json) =>
    _$DetectionImpl(
      id: json['id'] as String,
      panelId: json['panel_id'] as String,
      panelName: json['panel_name'] as String,
      type: $enumDecode(_$DetectionTypeEnumMap, json['type']),
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detected_at'] as String),
      imageUrl: json['image_url'] as String?,
      alertId: json['alert_id'] as String?,
    );

Map<String, dynamic> _$$DetectionImplToJson(_$DetectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'panel_id': instance.panelId,
      'panel_name': instance.panelName,
      'type': _$DetectionTypeEnumMap[instance.type]!,
      'confidence': instance.confidence,
      'detected_at': instance.detectedAt.toIso8601String(),
      'image_url': instance.imageUrl,
      'alert_id': instance.alertId,
    };

const _$DetectionTypeEnumMap = {
  DetectionType.normal: 'normal',
  DetectionType.soiling: 'soiling',
  DetectionType.crack: 'crack',
};

_$DetectionsResponseImpl _$$DetectionsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$DetectionsResponseImpl(
      detections: (json['detections'] as List<dynamic>)
          .map((e) => Detection.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$$DetectionsResponseImplToJson(
        _$DetectionsResponseImpl instance) =>
    <String, dynamic>{
      'detections': instance.detections,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
