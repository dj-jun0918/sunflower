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
      rtspUrl: json['rtspUrl'] as String?,
      status: $enumDecodeNullable(_$PanelStatusEnumMap, json['status']) ??
          PanelStatus.normal,
      lastDetectionAt: json['lastDetectionAt'] == null
          ? null
          : DateTime.parse(json['lastDetectionAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PanelImplToJson(_$PanelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rtspUrl': instance.rtspUrl,
      'status': _$PanelStatusEnumMap[instance.status]!,
      'lastDetectionAt': instance.lastDetectionAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
      rtspUrl: json['rtspUrl'] as String?,
    );

Map<String, dynamic> _$$PanelRequestImplToJson(_$PanelRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rtspUrl': instance.rtspUrl,
    };
