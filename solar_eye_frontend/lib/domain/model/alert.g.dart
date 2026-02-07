// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertImpl _$$AlertImplFromJson(Map<String, dynamic> json) => _$AlertImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      panelId: json['panelId'] as String?,
      panelName: json['panelName'] as String?,
      detectionId: json['detectionId'] as String?,
      snapshotUrl: json['snapshotUrl'] as String?,
    );

Map<String, dynamic> _$$AlertImplToJson(_$AlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'panelId': instance.panelId,
      'panelName': instance.panelName,
      'detectionId': instance.detectionId,
      'snapshotUrl': instance.snapshotUrl,
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.info: 'info',
  AlertSeverity.warning: 'warning',
  AlertSeverity.danger: 'danger',
};

_$AlertsResponseImpl _$$AlertsResponseImplFromJson(Map<String, dynamic> json) =>
    _$AlertsResponseImpl(
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$$AlertsResponseImplToJson(
        _$AlertsResponseImpl instance) =>
    <String, dynamic>{
      'alerts': instance.alerts,
      'total': instance.total,
      'unreadCount': instance.unreadCount,
    };
