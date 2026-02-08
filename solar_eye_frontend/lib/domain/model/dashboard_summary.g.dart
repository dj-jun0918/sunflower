// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardSummaryImpl _$$DashboardSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardSummaryImpl(
      totalPanels: (json['totalPanels'] as num).toInt(),
      normalPanels: (json['normalPanels'] as num).toInt(),
      warningPanels: (json['warningPanels'] as num).toInt(),
      dangerPanels: (json['dangerPanels'] as num).toInt(),
      todayDetections: TodayDetections.fromJson(
          json['todayDetections'] as Map<String, dynamic>),
      efficiencyRate: (json['efficiencyRate'] as num).toDouble(),
      currentOutputKw: (json['currentOutputKw'] as num).toDouble(),
      todayRevenue: (json['todayRevenue'] as num).toInt(),
      yesterdayRevenueDiff: (json['yesterdayRevenueDiff'] as num).toInt(),
      recentAlerts: (json['recentAlerts'] as List<dynamic>)
          .map((e) => RecentAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DashboardSummaryImplToJson(
        _$DashboardSummaryImpl instance) =>
    <String, dynamic>{
      'totalPanels': instance.totalPanels,
      'normalPanels': instance.normalPanels,
      'warningPanels': instance.warningPanels,
      'dangerPanels': instance.dangerPanels,
      'todayDetections': instance.todayDetections,
      'efficiencyRate': instance.efficiencyRate,
      'currentOutputKw': instance.currentOutputKw,
      'todayRevenue': instance.todayRevenue,
      'yesterdayRevenueDiff': instance.yesterdayRevenueDiff,
      'recentAlerts': instance.recentAlerts,
    };

_$TodayDetectionsImpl _$$TodayDetectionsImplFromJson(
        Map<String, dynamic> json) =>
    _$TodayDetectionsImpl(
      total: (json['total'] as num).toInt(),
      normal: (json['normal'] as num).toInt(),
      soiling: (json['soiling'] as num).toInt(),
      crack: (json['crack'] as num).toInt(),
    );

Map<String, dynamic> _$$TodayDetectionsImplToJson(
        _$TodayDetectionsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'normal': instance.normal,
      'soiling': instance.soiling,
      'crack': instance.crack,
    };

_$RecentAlertImpl _$$RecentAlertImplFromJson(Map<String, dynamic> json) =>
    _$RecentAlertImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
    );

Map<String, dynamic> _$$RecentAlertImplToJson(_$RecentAlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };
