// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetectionImpl _$$DetectionImplFromJson(Map<String, dynamic> json) =>
    _$DetectionImpl(
      id: json['id'] as String,
      panelId: json['panelId'] as String,
      panelName: json['panelName'] as String,
      type: $enumDecode(_$DetectionTypeEnumMap, json['type']),
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      alertId: json['alertId'] as String?,
    );

Map<String, dynamic> _$$DetectionImplToJson(_$DetectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'panelId': instance.panelId,
      'panelName': instance.panelName,
      'type': _$DetectionTypeEnumMap[instance.type]!,
      'confidence': instance.confidence,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'alertId': instance.alertId,
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
