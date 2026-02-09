// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PanelImpl _$$PanelImplFromJson(Map<String, dynamic> json) => _$PanelImpl(
      id: _idToString(json['id']),
      name: json['name'] as String,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rtspUrl: json['rtsp_url'] as String?,
      status: $enumDecodeNullable(_$PanelStatusEnumMap, json['status']) ??
          PanelStatus.normal,
      lastDetectionAt: json['last_detection_at'] == null
          ? null
          : DateTime.parse(json['last_detection_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PanelImplToJson(_$PanelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rtsp_url': instance.rtspUrl,
      'status': _$PanelStatusEnumMap[instance.status]!,
      'last_detection_at': instance.lastDetectionAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$PanelStatusEnumMap = {
  PanelStatus.normal: 'active',
  PanelStatus.warning: 'maintenance',
  PanelStatus.danger: 'error',
  PanelStatus.inactive: 'inactive',
};

_$PanelRequestImpl _$$PanelRequestImplFromJson(Map<String, dynamic> json) =>
    _$PanelRequestImpl(
      name: json['name'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rtspUrl: json['rtsp_url'] as String?,
    );

Map<String, dynamic> _$$PanelRequestImplToJson(_$PanelRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rtsp_url': instance.rtspUrl,
    };
